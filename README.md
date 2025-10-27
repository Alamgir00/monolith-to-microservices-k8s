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
