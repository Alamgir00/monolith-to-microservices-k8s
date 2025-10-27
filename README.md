# Monolith → Microservices (Kubernetes) — Demo

This repo demonstrates splitting a monolith into two microservices and deploying them to AWS EKS with CI/CD.

## What is included
- Two Python Flask microservices (service-a calls service-b).
- Dockerfiles for both services.
- Kubernetes manifests with production best-practices:
  - resource requests/limits
  - liveness/readiness probes
  - HorizontalPodAutoscaler
  - Ingress (TLS via cert-manager)
- Terraform to provision EKS + ECR
- GitHub Actions CI/CD pipeline to build images, push to ECR, and deploy to EKS.

## How to use (quick)
1. Create GitHub repo and push this project.
2. Create AWS resources with Terraform:


cd infra
terraform init
terraform apply -var="region=us-east-1"
3. Set GitHub repo secrets (AWS, EKS_CLUSTER_NAME, AWS_ACCOUNT_ID).
4. Push to `main` — GitHub Actions will build, push, and deploy.
5. Update DNS to point to the ingress (ALB/NGINX as per your cluster).

## Production checklist
- Use private subnets for worker nodes and public subnets for load balancers only.
- Use IRSA for pod-level IAM (no node IAM keys).
- Use HTTPS with ACM certs or cert-manager.
- Configure centralized logging (Fluentd -> CloudWatch/ELK) and metrics (Prometheus / Grafana).
- Setup canary or blue/green deployment workflow (Argo Rollouts or flagging).
- Add network policies and pod security admission controls, resource quotas, and limit ranges.

6. How to create the GitHub repo and push (easy)

Assuming you have git and gh (GitHub CLI) installed and authenticated.

# create local folder and files (paste files from above)
mkdir monolith-to-microservices-k8s
cd monolith-to-microservices-k8s
# create folders and files as per structure...
git init
git add .
git commit -m "Initial commit: monolith->microservices demo, k8s + infra + CI/CD"
gh repo create skalamgir/monolith-to-microservices-k8s --public --source=. --remote=origin
git push -u origin main


If you don’t use gh, create repo in GitHub UI and follow the push instructions.

## Quick production hardening checklist (things to add after POC)

**Use private subnets and NAT for outbound.

Manage credentials with IRSA (IAM Roles for Service Accounts) — no nodes with broad IAM.

Replace long-lived AWS keys in GitHub with OIDC integrations.

Use Helm charts (templated manifests) for parameterization & versioning.

Add Terraform state backend (S3 + DynamoDB locking) — do not store state locally.

Add autoscaling groups + cluster autoscaler for worker nodes.

Add canary or blue/green deploys (Argo Rollouts, Flagger).

Add Prometheus / Grafana, Fluentd/CloudWatch, and tracing (Jaeger/X-Ray).

Add network policies, pod security policies (PSA), and resource quotas.

Add integration tests and security scanning (Trivy, kube-bench, Snyk).**


## IAM / GitHub secrets recommended permissions (minimum)

ECR Push rights (**ecr:BatchGetImage, ecr:PutImage, ecr:InitiateLayerUpload, ecr:CompleteLayerUpload, ecr:GetAuthorizationToken**)

EKS Describe and Update kubeconfig (**eks:DescribeCluster**)

EC2/VPC creation (**for infra via Terraform**) — ideally restrict to infra account.

Use separate IAM user/role per environment.
