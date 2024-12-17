## Initial Plan

0. Containerise application using Docker (create Dockerfile)

1. Setup a cluster locally

2. Create helm chart

3. Create terrform script to deploy heml chart

4. Deploy the helm chart

## Nice-to-haves

5. Setup kubernetes (k3s) on Raspberry PI

6. Deploy the helm chart on Raspberry PI

7. Expose Raspberry PI to the internet

8. Expose k8s deployment via service (ingress)

9. Investigate secret management

10. ??

11. Profit

## Design Decisions

### Containerisation of Python Application

- Created a dockerfile, exposing a number of useful environment variables to the container,
- Run application as a module instead of a script.
- Used a multi-stage build to reduce the size of the final image.
- Used production-grade WSGserver (Granian) to ensure the application can serve and scale as needed.
- Used pipenv to simplify dependency management & version locking.
- Investigated multi-stage Dockerfile builds, but decided against (reduction in image size insignifcant).

### Helm Chart

- Created a helm chart to deploy python applications to Kubernetes.
- Chart creates a deployment, service and (optionally) ingress.
- By default application is exposed via service (loadbalancer).
- Chart uses secrets to pass sensitive environment variables to the container.
- Secrets are

### Tradeoffs with the current Design:

1. Infrastructure configuration stored in the same repository as the code:

- Application lifecycle is not decoupled from the infrastructure lifecycle (Harder to update 1 without updating the other)
- Changes to infrastructure (e.g: updating environment variables, or adding a new environment) could trigger build/release of the application.
- More difficult to roll-back changes to infrastructure without rolling back the application as well.
- As number of applications grows, infrastructure becomes more dispersed, and harder to manage.

2. Using Terraform for kubernetes resource management:

- Additional layer of complexity to infrastructure tooling for little benefit.
- Terraform Plans effectively useless as they only show changes to the helm resource, not changes to the underlying kubernetes manifests/resources.
- e.g: how changes to helm-release terraform resource will affect the deployment, service, ingress, etc. of the application.
- Kubernetes Errors are more difficult to debug (Terraform does not provide as useful error messages).
- Changes to helm templates/chart require a new release of chart for terraform to pick up the changes.
- Occasionally hangs on apply/destroy, requiring manual intervention to fix the state.

3. Secret Management:

- Secrets are stored locally, and not comitted to the repository.
- Secrets are not managed by a secret management tool, and are not rotated.
