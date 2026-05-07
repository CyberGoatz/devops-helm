# devops-helm Architecture

This document describes the current `devops-helm` deployment architecture: the Helm chart layers, the services deployed by the platform, what each service does, how requests flow through the cluster, and where data is stored.

The stack is centered around the `crczp-head` umbrella chart. It deploys the web frontend, Keycloak, platform APIs, sandbox orchestration, remote access, logging, caching, and supporting data services.

## High-level topology

```text
Browser / API client
  |
  v
Traefik IngressRoute
  |
  +--> /                                  angular-frontend
  +--> /keycloak                          keycloak-service
  +--> /training/api/v1/                  training-service
  +--> /adaptive-training/api/v1/         adaptive-training-service
  +--> /sandbox-service/api/v1/           sandbox-service
  +--> /guacamole/api/v1/                 guacamole-service
  +--> /mitre-technique-service/api/v1/   mitre-service
  +--> /user-and-group/api/v1/            uag-service
  |
  +--> internal-only services:
       answers-storage
       elasticsearch-service
       smart-assistant
       training-feedback-service
       crczp-redis
       crczp-elasticsearch
       crczp-logstash
       crczp-syslog-ng
       crczp-guacd
       postgres-rw.cnpg-system.svc.cluster.local
```

The default local/Vagrant installation uses `172.19.0.22` as `global.headHost`. For a domain-based deployment, the same ingress templates add a `Host(...)` match for `global.headHost`.

## Helm chart layers

| Chart | Purpose |
| --- | --- |
| `crczp-certs` | Creates the TLS secret referenced by ingress routes. It supports user-provided certificates, self-signed certificates, and cert-manager/ACME-backed certificates depending on values. |
| `crczp-postgres` | Deploys the CloudNativePG `Cluster` named `postgres`. Platform service databases are created later by `crczp-head` hooks. |
| `crczp-gen-users` | Optionally generates local demo users and stores them in a `generated-users` secret consumed by Keycloak and UAG templates. |
| `crczp-head` | Umbrella chart for the platform runtime: frontend, identity, APIs, sandbox orchestration, logging, Redis, Elasticsearch, and service hooks. |
| `crczp-head/charts/common` | Library chart used by most services for common Deployment, Service, PVC, labels, image pull secret, mounts, and readiness probe templates. |

## Public ingress and API routing

The main ingress route is `crczp-ingress` in `helm/crczp-head/templates/ingress.yaml`. It exposes all services in `global.services` where `ingressAutoexpose: true`.

| Public path | Kubernetes service | Port | Purpose |
| --- | --- | ---: | --- |
| `/` | `angular-frontend` | 8000 | Existing Angular platform UI. |
| `/adaptive-training/api/v1/` | `adaptive-training-service` | 8082 | Adaptive training API. |
| `/guacamole/api/v1/` | `guacamole-service` | 8089 | Remote access session API. |
| `/mitre-technique-service/api/v1/` | `mitre-service` | 8001 | MITRE technique visualization API. |
| `/sandbox-service/api/v1/` | `sandbox-service` | 8000 | Sandbox pool, definition, allocation, and provisioning API. |
| `/training/api/v1/` | `training-service` | 8083 | Linear training API. |
| `/user-and-group/api/v1/` | `uag-service` | 8084 | User, group, role, and microservice registry API. |
| `/keycloak` | `keycloak-service` | 8080 | Keycloak realm login, registration, account, and OIDC endpoints. |

These services have cluster Services but are not generally exposed through the automatic public ingress:

| Internal path/service | Kubernetes service | Port | Purpose |
| --- | --- | ---: | --- |
| `/answers-storage/api/v1/` | `answers-storage` | 8087 | Internal answer storage used by training services. |
| `/elasticsearch-service/api/v1/` | `elasticsearch-service` | 8085 | Internal API wrapper over raw Elasticsearch. |
| `/adaptive-smart-assistant/api/v1/` | `smart-assistant` | 8086 | Internal adaptive smart assistant API. |
| `/training-feedback/api/v1/` | `training-feedback-service` | 8088 | Internal feedback API. |
| Redis | `crczp-redis` | 6379 | Cache and queue backend. |
| Elasticsearch HTTP | `crczp-elasticsearch` | 9200 | Raw Elasticsearch node. |
| Logstash | `crczp-logstash` | 10514, 10515, 10516 | Syslog pipeline inputs. |
| Syslog | `crczp-syslog-ng` | 514, 601, 6514 | Internal syslog collector. |
| guacd | `crczp-guacd` | 4822 | Remote access protocol daemon. |

## Services

### `angular-frontend`

The Angular frontend is the existing in-cluster web UI served at `/`. It is built from `ghcr.io/cyberrangecz/frontend-platform/frontend-platform:v2.5.5`.

It reads its backend URLs and role configuration from its chart ConfigMap. Users authenticate through Keycloak and then call the exposed backend APIs through Traefik.

The new Next.js `cyber-goatz-frontend` is not deployed by this Helm stack right now. It is integrated through Keycloak client redirect configuration only.

### `crczp-keycloak`

Keycloak is the identity provider for the platform. It is deployed through Keycloak Operator custom resources and exposed at `/keycloak`.

Responsibilities:

- Owns the `CRCZP` realm.
- Provides login, registration, password reset, email verification, terms acceptance, and social login when configured.
- Issues OIDC tokens to the Angular client and the CyberGoatz/Next.js client.
- Stores its state in the `keycloak` PostgreSQL database.
- Mounts the `cyber-goatz` login theme from the `keycloak-theme-cyber-goatz` ConfigMap when theme support is enabled.
- Runs a post-install/post-upgrade sync hook to apply realm login settings, password policy, SMTP settings, theme selection, and optional Google identity provider configuration.

Important templates:

- `keycloak-realm.yaml` creates the realm.
- `keycloak-crczp-client.yaml` creates the Angular/platform OIDC client.
- `keycloak-cybergoatz-client.yaml` creates the CyberGoatz/Next.js OIDC client.
- `keycloak-user.yaml` creates local Keycloak users from configured and generated users.
- `keycloak-hook-sync-realm.yaml` reconciles realm settings after install/upgrade.

### `uag-service`

The user-and-group service is the platform authorization and service registry authority. It is built from `ghcr.io/cyberrangecz/backend-user-and-group/user-and-group-service:v1.2.0`.

Responsibilities:

- Stores platform users, groups, roles, and role assignments.
- Stores microservice registration records.
- Maps authenticated Keycloak users to platform users.
- Provides user/group/role APIs to the frontend and other backend services.
- Supplies role checks used by training, adaptive training, sandbox, guacamole, feedback, and Elasticsearch APIs.

State:

- PostgreSQL database: `user-and-group`.

### `training-service`

The training service is the standard linear training backend. It is built from `ghcr.io/cyberrangecz/backend-training/training-service:v1.2.2`.

Responsibilities:

- Manages linear training definitions.
- Manages training instances.
- Exposes the training catalog and trainee-facing training run APIs.
- Coordinates training runs with sandbox pools and sandbox allocations.
- Talks to UAG for user and role data.
- Talks to sandbox-service for pool and allocation data.
- Talks to answers-storage and training-feedback for related training data.
- Emits audit logs to syslog and stores/searches event data through Elasticsearch.

State:

- PostgreSQL database: `training`.
- Uses raw Elasticsearch through the configured Elasticsearch host and the `elasticsearch-service` API where needed.

### `adaptive-training-service`

The adaptive training service is the adaptive training backend. It is built from `ghcr.io/cyberrangecz/backend-adaptive-training/adaptive-training-service:v1.2.0`.

Responsibilities:

- Manages adaptive training definitions and instances.
- Manages adaptive training runs.
- Coordinates adaptive training with sandbox-service.
- Integrates with smart-assistant for adaptive guidance.
- Uses UAG for identity and authorization data.
- Emits audit logs to syslog and stores/searches event data through Elasticsearch.

State:

- PostgreSQL database: `crczp-adaptive-training`.

### `sandbox-service`

The sandbox service is the provisioning and lifecycle manager for sandbox environments. It is built from `ghcr.io/cyberrangecz/backend-sandbox-service/sandbox-service:v1.6.2`.

Responsibilities:

- Manages sandbox definitions.
- Creates and tracks sandbox pools.
- Creates and tracks sandbox allocations.
- Reports sandbox pool capacity and availability to training services.
- Provisions cloud infrastructure for sandboxes through provider-specific configuration.
- Runs Terraform and Ansible stages.
- Talks to UAG for authorization data.
- Talks to answers-storage where sandbox answers/events are needed.
- Uses Redis for caching and background queue coordination.
- Uses a PVC for Ansible runner/shared runtime data.

State and infrastructure:

- PostgreSQL database: `sandbox-service`.
- Redis: `crczp-redis`.
- PVC: `sandbox-service`.
- Secrets: provider credentials, Django secret key, proxy key, and optional Keystone CA certificate.
- Service account/RBAC: allows sandbox pods to create and manage Kubernetes resources needed by Terraform and Ansible stages.

Worker deployments:

- `sandbox-service-worker-openstack`: handles OpenStack-related background jobs.
- `sandbox-service-worker-ansible`: handles Ansible stage jobs.
- `sandbox-service-worker-default`: handles default/background sandbox jobs.

Provider support is controlled through values. The current values include OpenStack-style settings and Azure provider placeholders.

### `guacamole-service`

The guacamole service is the backend API that connects platform users to remote access sessions. It is built from `ghcr.io/cyberrangecz/backend-guacamole/guacamole-service:v1.0.1`.

Responsibilities:

- Creates and manages Guacamole connection/session metadata.
- Talks to sandbox-service to discover sandbox access targets.
- Talks to UAG for user and role checks.
- Talks to `crczp-guacd` for remote access protocol handling.
- Emits audit logs to syslog and stores/searches related event data through Elasticsearch.

State:

- PostgreSQL database: `guacamole`.

### `crczp-guacd`

`crczp-guacd` is the Apache Guacamole daemon built from `ghcr.io/cyberrangecz/docker-dependencies-mirror/guacd:1.6.0`.

Responsibilities:

- Handles the low-level remote desktop/SSH/VNC/RDP protocol sessions used by Guacamole.
- Provides the `4822` service endpoint consumed by `guacamole-service`.
- Uses a PVC for drive and recording data.

### `answers-storage`

The answers storage service is an internal backend built from `ghcr.io/cyberrangecz/backend-answers-storage/answers-storage-service:v1.2.0`.

Responsibilities:

- Stores answers or answer-related events produced by training and sandbox workflows.
- Serves internal APIs used by training-related services.
- Uses UAG/OIDC configuration for secured service access.

State:

- PostgreSQL database: `crczp-answers-storage`.

### `training-feedback-service`

The training feedback service is an internal backend built from `ghcr.io/cyberrangecz/backend-training-feedback/training-feedback-service:v1.2.0`.

Responsibilities:

- Stores and serves feedback for training runs.
- Provides internal APIs consumed by training workflows.
- Uses UAG for authorization data.
- Talks to `elasticsearch-service` where search/event access is needed.

State:

- PostgreSQL database: `crczp-training-feedback`.

### `smart-assistant`

The adaptive smart assistant service is an internal backend built from `ghcr.io/cyberrangecz/backend-adaptive-smart-assistant/adaptive-smart-assistant-service:v1.2.0`.

Responsibilities:

- Provides assistant functionality for adaptive training.
- Talks to adaptive-training-service, UAG, sandbox-service, and `elasticsearch-service`.
- Uses the shared TLS certificate secret as a Java trust store input through the chart mount.

State:

- PostgreSQL database: `crczp-adaptive-smart-assistant`.

### `mitre-service`

The MITRE technique service is built from `ghcr.io/cyberrangecz/backend-mitre-technique-service/mitre-technique-service:v1.1.0`.

Responsibilities:

- Provides MITRE ATT&CK technique visualization support.
- Calls training and adaptive-training visualization endpoints.
- Uses Redis DB `1` for caching.

### `elasticsearch-service`

The Elasticsearch service is an internal API wrapper built from `ghcr.io/cyberrangecz/backend-elasticsearch-service/elasticsearch-service-service:v1.2.0`.

Responsibilities:

- Provides a secured platform API in front of raw Elasticsearch.
- Talks to raw Elasticsearch at `crczp-elasticsearch:9200`.
- Talks to UAG for role and authorization checks.
- Serves search/event data to platform services that should not query raw Elasticsearch directly.

This is separate from the raw `crczp-elasticsearch` data node.

### `crczp-elasticsearch`

`crczp-elasticsearch` is the raw Elasticsearch node built from `docker.elastic.co/elasticsearch/elasticsearch:8.1.2`.

Responsibilities:

- Stores platform audit logs and event/search data.
- Receives writes from Logstash and direct service integrations.
- Exposes internal ports `9200` and `9300`.
- Runs a post-install hook that creates index templates and max result window settings.

State:

- PVC: `crczp-elasticsearch`.
- Default chart size: `500Mi`.

### `crczp-logstash`

`crczp-logstash` is built from `docker.elastic.co/logstash/logstash:8.1.2`.

Responsibilities:

- Receives parsed syslog streams from `crczp-syslog-ng`.
- Runs configured pipelines for platform/audit data.
- Writes processed records into `crczp-elasticsearch`.

### `crczp-syslog-ng`

`crczp-syslog-ng` is built from `ghcr.io/cyberrangecz/docker-dependencies-mirror/syslog-ng:latest`.

Responsibilities:

- Receives syslog/audit traffic from platform services and sandbox environments.
- Exposes an external load balancer service for syslog traffic.
- Forwards logs to Logstash pipelines.

### `crczp-redis`

`crczp-redis` is built from `ghcr.io/cyberrangecz/docker-dependencies-mirror/redis:6.2.6`.

Responsibilities:

- Provides shared Redis for sandbox-service queues/caches.
- Provides Redis DB `1` for MITRE cache data.

### `crczp-postgres`

`crczp-postgres` deploys a CloudNativePG PostgreSQL cluster named `postgres`.

Responsibilities:

- Provides the shared PostgreSQL server for platform services.
- Exposes the writable service as `postgres-rw.cnpg-system.svc.cluster.local`.
- Stores Keycloak state and each backend service database.

The `crczp-head` pre-install hook connects as the configured PostgreSQL admin user and creates/updates service database users and databases.

### `crczp-certs`

`crczp-certs` creates the TLS secret referenced by all Traefik ingress routes through `global.tlsSecretName`.

Responsibilities:

- Creates `crczp-certs` by default.
- Supports IP-based, domain-based, self-signed, and user-provided certificate flows.
- Allows Keycloak and platform ingress routes to share the same TLS secret.

### `crczp-gen-users`

`crczp-gen-users` optionally creates a `generated-users` secret.

Responsibilities:

- Generates local demo users when `global.userCount` is greater than zero.
- Makes generated users available to Keycloak and UAG templates through `lookup`.
- Lets the post-install hook add generated users to the right default group.

## Data stores and persistence

| Store | Backing service | Consumers | Purpose |
| --- | --- | --- | --- |
| PostgreSQL `keycloak` | `crczp-postgres` | Keycloak | Realm, users, clients, login state. |
| PostgreSQL `user-and-group` | `crczp-postgres` | `uag-service` | Users, groups, roles, microservice registrations. |
| PostgreSQL `training` | `crczp-postgres` | `training-service` | Linear training definitions, instances, runs. |
| PostgreSQL `crczp-adaptive-training` | `crczp-postgres` | `adaptive-training-service` | Adaptive training data. |
| PostgreSQL `sandbox-service` | `crczp-postgres` | `sandbox-service` | Sandbox definitions, pools, allocations, lifecycle records. |
| PostgreSQL `guacamole` | `crczp-postgres` | `guacamole-service` | Remote access/session metadata. |
| PostgreSQL `crczp-answers-storage` | `crczp-postgres` | `answers-storage` | Answer-related records. |
| PostgreSQL `crczp-training-feedback` | `crczp-postgres` | `training-feedback-service` | Training feedback records. |
| PostgreSQL `crczp-adaptive-smart-assistant` | `crczp-postgres` | `smart-assistant` | Adaptive assistant state. |
| Redis DB `0` | `crczp-redis` | `sandbox-service` | Sandbox queues and cache data. |
| Redis DB `1` | `crczp-redis` | `mitre-service` | MITRE technique cache. |
| Elasticsearch data PVC | `crczp-elasticsearch` | Logstash, backend services, `elasticsearch-service` | Audit, event, and search data. |
| Sandbox PVC | `sandbox-service` | Sandbox API and workers | Shared runner/provisioning data. |
| guacd PVC | `crczp-guacd` | Guacamole daemon | Drive and recording data. |

## Identity, roles, and default groups

Keycloak authenticates users. UAG authorizes them inside the platform.

```text
User logs in
  |
  v
Keycloak issues OIDC token
  |
  v
Frontend calls platform API with bearer token
  |
  v
Backend service validates token and asks/uses UAG for user, group, and role context
```

The `head-hook-postinstall` hook waits for microservices to register in UAG, then creates default groups and role assignments.

Default groups:

| Group | Purpose |
| --- | --- |
| `All Mighty Users` | Full platform admin group. |
| `Instructor` | Designer/organizer group for training and sandbox work. |
| `DEFAULT-GROUP` | Default non-admin user group used by generated or configured regular users. |

`All Mighty Users` receives:

- `ROLE_USER_AND_GROUP_ADMINISTRATOR`
- `ROLE_TRAINING_ADMINISTRATOR`
- `ROLE_TRAINING_ORGANIZER`
- `ROLE_TRAINING_DESIGNER`
- `ROLE_TRAINING_TRAINEE`
- `ROLE_ADAPTIVE_TRAINING_ADMINISTRATOR`
- `ROLE_ADAPTIVE_TRAINING_ORGANIZER`
- `ROLE_ADAPTIVE_TRAINING_DESIGNER`
- `ROLE_ADAPTIVE_TRAINING_TRAINEE`
- `ROLE_SANDBOX-SERVICE_ADMIN`
- `ROLE_SANDBOX-SERVICE_ORGANIZER`
- `ROLE_SANDBOX-SERVICE_DESIGNER`
- `ROLE_SANDBOX-SERVICE_TRAINEE`

`Instructor` receives:

- `ROLE_TRAINING_ORGANIZER`
- `ROLE_TRAINING_DESIGNER`
- `ROLE_ADAPTIVE_TRAINING_ORGANIZER`
- `ROLE_ADAPTIVE_TRAINING_DESIGNER`
- `ROLE_SANDBOX-SERVICE_ORGANIZER`
- `ROLE_SANDBOX-SERVICE_DESIGNER`

Configured users with `admin: true` are assigned to `All Mighty Users`. Other configured/generated users are assigned to `DEFAULT-GROUP`.

## Training and sandbox lifecycle

```text
Instructor/admin creates sandbox definition
  |
  v
sandbox-service provisions pool using provider config
  |
  v
Instructor/admin creates training definition and training instance
  |
  v
training-service links the instance to a sandbox pool
  |
  v
Trainee opens catalog and starts a run
  |
  v
training-service requests/uses sandbox allocation information
  |
  v
sandbox-service assigns an available sandbox allocation
  |
  v
guacamole-service + crczp-guacd provide remote access
  |
  v
answers, events, feedback, and audit logs are stored
```

The important ownership boundary is that training services own training definitions, instances, and runs, while sandbox-service owns sandbox definitions, pools, allocations, provider orchestration, and available capacity.

## Logging and audit flow

```text
Platform services and sandbox components
  |
  v
crczp-syslog-ng
  |
  v
crczp-logstash
  |
  v
crczp-elasticsearch
  |
  v
elasticsearch-service
  |
  v
Training/adaptive/guacamole/frontend APIs that need event/search data
```

Services also contain direct Elasticsearch host configuration where needed, but the secured `elasticsearch-service` is the platform API boundary for querying event/search data.

## Helm hooks and startup behavior

| Hook/template | When it runs | Purpose |
| --- | --- | --- |
| `github-secret.yaml` | `pre-install` | Creates image pull secret for GHCR-based images. |
| `db-resources-hook-pre-install.yaml` | `pre-install` | Waits for PostgreSQL, creates/updates service database roles, creates databases, and grants privileges. |
| `db-resources-hook-post-install.yaml` | `post-install` | Waits for service registration, creates default UAG groups, assigns roles, and assigns configured/generated users to groups. |
| `crczp-elasticsearch/hook-post-install.yaml` | `post-install` | Creates Elasticsearch index templates and settings. |
| `crczp-keycloak/keycloak-hook-sync-realm.yaml` | `post-install, post-upgrade` | Applies Keycloak realm runtime settings after Keycloak is reachable. |

Most application deployments use the common Deployment template, which adds:

- Standard Helm/Kubernetes labels.
- `reloader.stakater.com/auto: "true"` annotation.
- Container image from chart values.
- TCP readiness probes for configured probe ports.
- ConfigMap/Secret/PVC mounts defined by chart values.
- Optional image pull secrets.

## Operational boundaries

- `devops-helm` currently deploys the Angular frontend as the in-cluster UI. The CyberGoatz Next.js frontend is external to this Helm stack unless a future chart is added for it.
- `vagrant-values.yaml` is environment-specific and may contain secrets. Architecture docs should reference placeholders and value keys, not real values.
- Public API exposure is controlled by `global.services.*.ingressAutoexpose` and explicit UAG/Keycloak ingress templates.
- Service-to-service communication is internal Kubernetes DNS using chart service names and ports.
- Sandbox cloud behavior depends on provider values and secrets. The Helm chart supplies configuration and workers; the actual cloud resources are created outside the cluster by sandbox-service provider orchestration.
