#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/deploy-devops-helm-aks.sh

Deploys the full devops-helm AKS stack using azure-values.yaml.

Environment overrides:
  VALUES_FILE           Default: azure-values.yaml
  CRCZP_NAMESPACE       Default: crczp
  TRAEFIK_NAMESPACE     Default: traefik
  TRAEFIK_PUBLIC_IP     Default: 52.224.190.214
  HEAD_HOST             Default: cybergoatz.chainscorehq.com
  TRAEFIK_VERSION       Default: 40.0.0
  CERT_MANAGER_VERSION  Default: v1.20.2
  HELM_TIMEOUT          Default: 40m
  CERT_TIMEOUT          Default: 15m
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 0 ]]; then
  usage
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVOPS_HELM_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

VALUES_FILE="${VALUES_FILE:-azure-values.yaml}"
CRCZP_NAMESPACE="${CRCZP_NAMESPACE:-crczp}"
TRAEFIK_NAMESPACE="${TRAEFIK_NAMESPACE:-traefik}"
TRAEFIK_PUBLIC_IP="${TRAEFIK_PUBLIC_IP:-52.224.190.214}"
HEAD_HOST="${HEAD_HOST:-cybergoatz.chainscorehq.com}"
TRAEFIK_VERSION="${TRAEFIK_VERSION:-40.0.0}"
CERT_MANAGER_VERSION="${CERT_MANAGER_VERSION:-v1.20.2}"
HELM_TIMEOUT="${HELM_TIMEOUT:-40m}"
CERT_TIMEOUT="${CERT_TIMEOUT:-15m}"

cd "${DEVOPS_HELM_DIR}"

if [[ ! -f "${VALUES_FILE}" ]]; then
  echo "Missing values file: ${DEVOPS_HELM_DIR}/${VALUES_FILE}" >&2
  exit 1
fi

echo "Adding Helm repositories"
helm repo add traefik https://traefik.github.io/charts --force-update
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo add stakater https://stakater.github.io/stakater-charts --force-update
helm repo add cloudnative-pg https://cloudnative-pg.github.io/charts --force-update
helm repo update

echo "Installing/upgrading Traefik without global HTTP redirect"
helm upgrade --install traefik traefik/traefik \
  --namespace "${TRAEFIK_NAMESPACE}" \
  --create-namespace \
  --version "${TRAEFIK_VERSION}" \
  --reset-values \
  --set service.type=LoadBalancer \
  --set service.spec.loadBalancerIP="${TRAEFIK_PUBLIC_IP}" \
  --wait

echo "Installing/upgrading cluster add-ons"
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
  --version "${CERT_MANAGER_VERSION}" \
  --set crds.enabled=true \
  --wait

echo "Installing/upgrading Keycloak CRDs and operators"
kubectl create namespace "${CRCZP_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n "${CRCZP_NAMESPACE}" -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.1/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
kubectl apply -n "${CRCZP_NAMESPACE}" -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.1/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml
kubectl apply -n "${CRCZP_NAMESPACE}" -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.1/kubernetes/kubernetes.yml

kubectl apply -n "${CRCZP_NAMESPACE}" -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_externalkeycloaks_crd.yaml
kubectl apply -n "${CRCZP_NAMESPACE}" -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_keycloakclients_crd.yaml
kubectl apply -n "${CRCZP_NAMESPACE}" -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_keycloakrealms_crd.yaml
kubectl apply -n "${CRCZP_NAMESPACE}" -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_keycloakusers_crd.yaml
kubectl apply -n "${CRCZP_NAMESPACE}" -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/role.yaml
kubectl apply -n "${CRCZP_NAMESPACE}" -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/role_binding.yaml
kubectl apply -n "${CRCZP_NAMESPACE}" -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/service_account.yaml
kubectl apply -n "${CRCZP_NAMESPACE}" -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/operator.yaml

echo "Building crczp-head chart dependencies"
helm dependency build helm/crczp-head

echo "Installing/upgrading platform charts from ${VALUES_FILE}"
helm upgrade --install crczp-postgres ./helm/crczp-postgres \
  --namespace cnpg-system \
  --create-namespace \
  -f "${VALUES_FILE}" \
  --wait

helm upgrade --install crczp-certs ./helm/crczp-certs \
  --namespace "${CRCZP_NAMESPACE}" \
  --create-namespace \
  -f "${VALUES_FILE}" \
  --wait

helm upgrade --install crczp-gen-users ./helm/crczp-gen-users \
  --namespace "${CRCZP_NAMESPACE}" \
  --create-namespace \
  -f "${VALUES_FILE}" \
  --wait

helm upgrade --install crczp-head ./helm/crczp-head \
  --namespace "${CRCZP_NAMESPACE}" \
  --create-namespace \
  -f "${VALUES_FILE}" \
  --timeout "${HELM_TIMEOUT}"

echo "Waiting for main platform deployments"
kubectl -n "${CRCZP_NAMESPACE}" rollout status deploy/angular-frontend --timeout=10m
kubectl -n "${CRCZP_NAMESPACE}" rollout status deploy/sandbox-service --timeout=10m
kubectl -n "${CRCZP_NAMESPACE}" rollout status deploy/sandbox-service-worker-ansible --timeout=10m
kubectl -n "${CRCZP_NAMESPACE}" rollout status deploy/sandbox-service-worker-default --timeout=10m
kubectl -n "${CRCZP_NAMESPACE}" rollout status deploy/sandbox-service-worker-openstack --timeout=10m
kubectl -n "${CRCZP_NAMESPACE}" rollout status deploy/uag-service --timeout=10m
kubectl -n "${CRCZP_NAMESPACE}" rollout status deploy/training-service --timeout=10m

echo "Waiting for TLS certificate"
if ! kubectl -n "${CRCZP_NAMESPACE}" wait certificate/crczp-certs --for=condition=Ready --timeout="${CERT_TIMEOUT}"; then
  echo "Certificate is not ready yet. Inspect with:" >&2
  echo "  kubectl -n ${CRCZP_NAMESPACE} get certificate,issuer,order,challenge" >&2
  echo "  kubectl -n ${CRCZP_NAMESPACE} describe certificate crczp-certs" >&2
  exit 1
fi

echo "Final status"
kubectl -n "${TRAEFIK_NAMESPACE}" get svc traefik
kubectl -n "${CRCZP_NAMESPACE}" get pods
helm -n "${CRCZP_NAMESPACE}" status crczp-head

echo "Checking Keycloak issuer"
curl -k "https://${HEAD_HOST}/keycloak/realms/CRCZP/.well-known/openid-configuration" \
  | grep -E '"issuer"|"authorization_endpoint"'

echo "Done"
