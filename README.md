# MyTomorrows Kubernetes Application

## Live Server address:

The kubernetes cluster & application are hosted locally on my raspberryPI.
The application is exposed via the address:

http://homesterdam.ydns.io:6666

## Deployment

### Prerequisites

- Docker
- Helm
- Kubernetes (kind/minikube/etc.)
- Terraform

### Steps

0. Setup a cluster locally or in cloud & configure as default context `kubectl config use-context CLUSTER_ID`

1. In `/infra` directory, create `secrets.auto.tfvars` file to store sensitive data:

```tf
app_secrets = {
  "SECRET_KEY" = "top-secret-key",
  "DB_PASSWORD" = "admin123",
}
```

2. Set path to kubeconfig file `export KUBE_CONFIG_PATH=~/.kube/config`:

3. Run `terraform init && terraform apply` to deploy the application to Kubernetes.

4. Verify successful deployment:

```sh
kubectl get pods -l 'app.kubernetes.io/name=mytomorrows-app'
export SERVICE_IP=$(kubectl get svc -l 'app.kubernetes.io/name=mytomorrows-app' -ojsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
curl -v $SERVICE_IP:8080
```

## Design Decisions

### Containerisation of Python Application

- Created a dockerfile, exposing a number of useful environment variables to the container,
- Run application as a module instead of a script.
- Used a multi-stage build to reduce the size of the final image.
- Used production-grade WSGI server (Granian) to ensure the application can serve and scale as needed.
- Used pipenv to simplify dependency management & version locking.
- Investigated multi-stage Dockerfile builds, decided against (reduction in image size insignifcant).

### Helm Chart

- Created a helm chart to deploy python applications to Kubernetes.
- Chart creates a deployment, service and (optionally) ingress.
- By default application is exposed via service (loadbalancer).
- Chart uses secrets to pass sensitive environment variables to the container.
- Secrets are generated values which are passed via helm values.yaml or terraform variables (Not secure for production).

### AWS Networking Strategy

The strategy I would adopt for deploying production-ready applications on AWS would greatly depend on the existing networking landscape of the organisation, and thee organisations plans for future growth.

In general, For kubernetes networking I would use the following components:

- A VPC with public and private subnets across multiple AZs to host k8s resources.
- For production: AWS Gateway API Controller to Manage North-Ingress to services.
- Amazon VPC Lattice to manage East/West (service to service) traffic.

### Scalability, Availability & Security

- Scalability is handled via Kubernetes deployment with configurable replica count
- Health checks implemented via liveness/readiness probes in deployment.yaml
- LoadBalancer service type enables horizontal scaling and traffic distribution
- Security implemented through:
  - Secret management for sensitive data
  - Containerized application with minimal dependencies
  - Networking isolation through VPC/subnets/firewall rules
  - Minimal roles for services following least privilege access
- Fault tolerance achieved through:
  - Multiple pod replicas
  - Self-healing through Kubernetes deployments
  - Health check probes for automatic recovery

### Tradeoffs/Concerns with the current Design:

1. Infrastructure configuration stored in the same repository as the code:

- App lifecycle not decoupled from the infrastructure lifecycle (Harder to update one, without updating the other)
- Changes to infrastructure (e.g: updating environment variables, or adding a new environment) could trigger build/release of the application.
- More difficult to roll-back changes to infrastructure without rolling back the application as well.
- As number of applications grows, infrastructure becomes dispersed and harder to manage.

2. Using Terraform for kubernetes resource management:

- Additional layer of complexity to infrastructure tooling for little benefit.
- Terraform Plans effectively useless as they only show changes to the helm resource, not changes to the underlying kubernetes manifests/resources.
- e.g: how changes to helm-release terraform resource will affect the deployment, service, ingress, etc. of the application.
- Kubernetes Errors are more difficult to debug (Terraform does not provide as useful error messages).
- Changes to helm templates/chart require a new release of chart for terraform to pick up the changes.
- Occasionally hangs on apply/destroy, requiring manual intervention to fix the state.

3. Secret Management:

- Secrets are stored locally, and not comitted to the repository, not a 3rd party secret management tool.
- This means they must be manually managed, or included in the cloud-based terraform CI/CD pipeline.

### Improvements:

To improve the soluton, and to address the trade-offs mentioned above, I recommend the following:

1. For CI/CD, I would use a dedicated K8s management tool, such as ArgoCD, or FluxCD. This would improve the reliability of CI/CD, and allow for more control over the deployment process.

2. I recommend consolidating managment of K8s application resources to a separate repo. This would enable you to manage the application & infrastructure lifecycles independently, and simplify roll-backs/updates.

3. For k8s Secret management, I recommend using a solution such as:

- `External Secrets` for secret management through Provider services (AWS Secrets Manager, etc.), or;
- `Sealed Secrets` to safely store secrets in git (secret resources deployed separately from app helm chart).

4. I would also improve the helm chart by:

- Adding gateway API template for ingress management.
- Adding service account & role binding resources.
- Improving scaling/autoscaling configuration.
- Improving support for different deployment strategies
- Support for prometheus metrics & logging.
