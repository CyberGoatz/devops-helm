# AKS Deployment Commands

This is the working command order for deploying CyberGoatz/CRCZP to AKS.

Assumptions:

- Current directory is `devops-helm`.
- `azure-values.yaml` exists locally and contains the real environment values and secrets.
- DNS `cybergoatz.chainscorehq.com` points to the Traefik public IP.
- `azure-values.yaml` uses `selfSigned: false` for a browser-trusted Let's Encrypt certificate.
- Do not install Traefik with a global HTTP-to-HTTPS redirect before the certificate is issued. HTTP-01 validation needs port 80.

## 1. Build And Push Sandbox Service

Use a new tag for every build.

```bash
cd ../backend-sandbox-service

az acr build \
  --registry cybergoatz \
  --image sandbox-service:v0.1.12 \
  .
```

Then update `devops-helm/azure-values.yaml`:

```yaml
sandbox:
  image:
    url: cybergoatz.azurecr.io/sandbox-service
    tag: v0.1.12
```

## 2. Helm Repos

```bash
cd ../devops-helm

helm repo add traefik https://traefik.github.io/charts
helm repo add jetstack https://charts.jetstack.io
helm repo add stakater https://stakater.github.io/stakater-charts
helm repo add cloudnative-pg https://cloudnative-pg.github.io/charts
helm repo update
```

## 3. Traefik

Use the fixed public IP. Do not set `ports.web.redirectTo` during initial certificate issuance.

```bash
helm upgrade --install traefik traefik/traefik \
  --namespace traefik \
  --create-namespace \
  --version 40.0.0 \
  --set service.type=LoadBalancer \
  --set service.spec.loadBalancerIP=52.224.190.214 \
  --wait
```

Verify:

```bash
kubectl -n traefik get svc traefik
kubectl -n traefik get deploy traefik -o yaml | grep redirections || true
curl -v http://cybergoatz.chainscorehq.com/.well-known/acme-challenge/test
```

Expected: no Traefik `redirections` args, and the curl result must not be `301` to `https://...:8443`.

## 4. Cluster Add-Ons

```bash
helm upgrade --install cnpg cloudnative-pg/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace \
  --set config.clusterWide=true \
  --wait

helm upgrade --install reloader stakater/reloader \
  --namespace reloader \
  --create-namespace \
  --wait

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.20.2 \
  --set crds.enabled=true \
  --wait
```

## 5. Keycloak Operators

```bash
kubectl create namespace crczp --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.1/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.1/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.1/kubernetes/kubernetes.yml

kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_externalkeycloaks_crd.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_keycloakclients_crd.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_keycloakrealms_crd.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_keycloakusers_crd.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/role.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/role_binding.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/service_account.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/operator.yaml
```

Verify:

```bash
kubectl -n crczp get pods | grep keycloak
```

## 6. Platform Charts

```bash
helm dependency build helm/crczp-head

helm upgrade --install crczp-postgres ./helm/crczp-postgres \
  --namespace cnpg-system \
  --create-namespace \
  -f azure-values.yaml \
  --wait

helm upgrade --install crczp-certs ./helm/crczp-certs \
  --namespace crczp \
  --create-namespace \
  -f azure-values.yaml \
  --wait

helm upgrade --install crczp-gen-users ./helm/crczp-gen-users \
  --namespace crczp \
  --create-namespace \
  -f azure-values.yaml \
  --wait

helm upgrade --install crczp-head ./helm/crczp-head \
  --namespace crczp \
  --create-namespace \
  -f azure-values.yaml \
  --timeout 40m
```

If `crczp-head` appears stuck, inspect from another terminal instead of cancelling immediately:

```bash
kubectl -n crczp get pods
kubectl -n crczp logs keycloak-0 --tail=100
kubectl -n crczp logs pod/keycloak-hook-sync-realm --tail=100
```

## 7. Certificate Verification

```bash
kubectl -n crczp get certificate,issuer,order,challenge
kubectl -n crczp describe certificate crczp-certs
```

Expected:

```text
certificate.cert-manager.io/crczp-certs   True
```

If the challenge stays pending and curl shows a redirect to `https://...:8443`, reset Traefik without the redirect:

```bash
helm upgrade traefik traefik/traefik \
  --namespace traefik \
  --version 40.0.0 \
  --reset-values \
  --set service.type=LoadBalancer \
  --set service.spec.loadBalancerIP=52.224.190.214 \
  --wait

kubectl -n crczp delete challenge --all --ignore-not-found
kubectl -n crczp delete order --all --ignore-not-found
```

Then watch:

```bash
kubectl -n crczp get certificate -w
```

## 8. Final Verification

```bash
kubectl -n crczp get pods
helm -n crczp status crczp-head

kubectl -n crczp get deploy sandbox-service \
  -o jsonpath='{.spec.template.spec.containers[*].image}{"\n"}'

curl -k https://cybergoatz.chainscorehq.com/keycloak/realms/CRCZP/.well-known/openid-configuration \
  | grep -E '"issuer"|"authorization_endpoint"'

curl -vI https://cybergoatz.chainscorehq.com 2>&1 \
  | grep -E 'issuer:|subject:|SSL certificate verify ok'
```

Expected Keycloak issuer:

```text
https://cybergoatz.chainscorehq.com/keycloak/realms/CRCZP
```

## 9. Deploy With The Script

The script deploys the full `devops-helm` AKS stack using `azure-values.yaml`. Build and push any service images first, update their tags in `azure-values.yaml`, then run:

```bash
./scripts/deploy-devops-helm-aks.sh
```

It installs or upgrades Traefik, CloudNativePG, Reloader, cert-manager, Keycloak operators, `crczp-postgres`, `crczp-certs`, `crczp-gen-users`, and `crczp-head`.

The script intentionally does not build Docker images. Image URLs and tags come from `azure-values.yaml`.
