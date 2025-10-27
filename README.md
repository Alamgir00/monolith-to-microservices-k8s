# 🏗️ Monolith → Microservices (Kubernetes on AWS EKS)

**Author:** Sk Alamgir Ali  
**Project Type:** DevOps | Cloud | CI/CD | Kubernetes | Terraform | Helm  
**Goal:** Demonstrate migration from a monolithic architecture to a microservices-based system, deployed on AWS EKS using Terraform, Docker, Helm, and GitHub Actions.

---

## 🚀 Project Overview

This project showcases a **realistic, production-lite migration** of a monolithic Python application into **microservices**, using containerization, infrastructure-as-code, and continuous delivery.

Each component — infrastructure provisioning, image building, and deployment — is **automated end-to-end**.

---

## 🎯 Objectives

✅ Split a monolith into independent **microservices**.  
✅ Containerize and store images in **Amazon ECR**.  
✅ Deploy scalable services to **Amazon EKS (Kubernetes)**.  
✅ Automate build → push → deploy using **GitHub Actions**.  
✅ Manage configurations using **Helm** for reusable deployment templates.  
✅ Maintain infrastructure with **Terraform (IaC)**.

---

## 🧩 Real-World “Lite” Use Case

A company running a legacy Python-based web app (monolithic) faces issues scaling and deploying updates.  
You refactor it into two microservices:

- **Service A (API Gateway / Frontend)** — handles user requests and routes them to backend services.  
- **Service B (Worker / Backend)** — processes logic and returns structured data.  

This separation improves:
- Fault isolation (no full outage if one service fails)
- Parallel deployments
- Autoscaling via HPA
- CI/CD efficiency (deploy only changed service)

---

## 🧱 Architecture Diagram (text)

```
Developer → GitHub → GitHub Actions
                 ↓
        Docker Build → ECR Push
                 ↓
           Terraform → EKS (Infra)
                 ↓
   Helm Deploy → Kubernetes Cluster
                 ↓
          Service A ↔ Service B
                 ↓
             ALB / Ingress
```

---

## 🧰 Tech Stack

| Layer | Technology | Purpose |
|-------|-------------|----------|
| **IaC** | Terraform | Provision AWS VPC, EKS, and ECR |
| **CI/CD** | GitHub Actions | Automate build & deployment |
| **Containerization** | Docker | Package services |
| **Orchestration** | Kubernetes (AWS EKS) | Deploy & scale |
| **Templating** | Helm | Manage multiple microservices |
| **App Framework** | Python Flask | Lightweight services |
| **Monitoring (extendable)** | Prometheus / Grafana (optional) | Observe system health |

---

## ⚙️ Setup & Deployment Steps

### 1️⃣ Prerequisites

- **AWS Account**
- **AWS CLI** configured locally
- **Terraform** ≥ 1.2  
- **Docker**, **kubectl**, **Helm**
- **GitHub account + repository**
- **IAM user/role** with permissions for EKS, ECR, and VPC
- (Optional) **GitHub CLI (`gh`)**

---

### 2️⃣ Clone or Download the Project

```bash
git clone https://github.com/<your-username>/monolith-to-microservices-k8s.git
cd monolith-to-microservices-k8s
```

Or unzip the provided `monolith-to-microservices-k8s.zip`.

---

### 3️⃣ Replace AWS Placeholders

Edit all files with your AWS info, or run the helper script:

```bash
chmod +x replace-placeholders.sh
AWS_ACCOUNT_ID=123456789012 AWS_REGION=us-east-1 ./replace-placeholders.sh
```

---

### 4️⃣ Initialize Terraform (create EKS & ECR)

```bash
cd infra
terraform init
terraform apply -auto-approve
```

Terraform will:
- Create a **VPC** with private/public subnets
- Create an **EKS cluster**
- Create two **ECR repositories** (`service-a`, `service-b`)

After apply, note:
```
ecr_service_a = <ECR repo URL A>
ecr_service_b = <ECR repo URL B>
cluster_id    = mono2micro-cluster
```

---

### 5️⃣ Configure GitHub Secrets

In your GitHub repo → **Settings → Secrets → Actions**  
Add these secrets:

| Secret Name | Example Value |
|--------------|---------------|
| AWS_REGION | us-east-1 |
| AWS_ACCOUNT_ID | 123456789012 |
| AWS_ACCESS_KEY_ID | your-key |
| AWS_SECRET_ACCESS_KEY | your-secret |
| EKS_CLUSTER_NAME | mono2micro-cluster |

---

### 6️⃣ CI/CD Pipeline (GitHub Actions)

Every push to `main` triggers:

1. **Checkout Code**  
2. **Login to AWS ECR**  
3. **Build Docker images** (`service-a`, `service-b`)  
4. **Push images** to ECR  
5. **Connect to EKS** using AWS CLI  
6. **Deploy to Kubernetes** via `kubectl apply` or Helm

> File: `.github/workflows/cicd.yml`

---

### 7️⃣ Verify Deployment

```bash
# Configure kubeconfig
aws eks update-kubeconfig --name mono2micro-cluster --region us-east-1

# Check pods & services
kubectl get pods -n prod
kubectl get svc -n prod
kubectl get hpa -n prod
```

Test service endpoint:

```bash
curl http://<ALB_or_INGRESS_DNS>/
# Expected:
# {"service":"service-a","downstream":{"service":"service-b","message":"hello from service-b"}}
```

---

## 🧠 How It Works (Behind the Scenes)

1. **Developers** push new code → triggers GitHub Action.  
2. The CI pipeline builds Docker images and pushes to ECR.  
3. The CD pipeline updates deployments on EKS via kubectl.  
4. Kubernetes runs pods (Service A, Service B) with autoscaling.  
5. **HPA** (Horizontal Pod Autoscaler) scales pods based on CPU.  
6. **Ingress Controller** (ALB or NGINX) routes traffic to Service A → Service B.

---

## 🔍 Troubleshooting

| Issue | Possible Fix |
|-------|---------------|
| Pods CrashLoopBackOff | Check image tags or environment variables |
| `kubectl` can’t connect | Run `aws eks update-kubeconfig` again |
| ECR push fails | Ensure correct IAM permissions |
| Ingress 404 | Wait for ALB to provision (~2-3 mins) |
| HPA not scaling | Install Kubernetes metrics server |

---

## 🛡️ Production Hardening Recommendations

✅ Use **private subnets** for EKS nodes.  
✅ Enable **IRSA (IAM Roles for Service Accounts)** for pods.  
✅ Use **GitHub OIDC** for short-lived credentials (no AWS keys).  
✅ Store Terraform state in **S3 + DynamoDB** for locking.  
✅ Enable **HTTPS (ACM)** and WAF on the ALB.  
✅ Add **Prometheus / Grafana** and **Fluentd / CloudWatch** for monitoring & logs.  
✅ Use **Trivy / Terrascan** for security scanning.  
✅ Enforce **NetworkPolicies** and resource quotas.

---

## 🧾 Clean Up

```bash
helm uninstall mono2micro --namespace prod
kubectl delete namespace prod

cd infra
terraform destroy -auto-approve
```

---

## 🧑‍💻 Future Enhancements

- Canary or Blue/Green deployments using **Argo Rollouts**  
- GitOps with **ArgoCD**  
- Observability stack: **Prometheus + Grafana + Loki**  
- Security scanning integrated into CI/CD  
- Multi-environment Helm values (dev/stage/prod)

---

## 🏁 Summary

**Result:**  
✅ Fully automated monolith → microservices migration pipeline  
✅ Cloud-native deployment on AWS EKS  
✅ CI/CD integrated with version control  
✅ Modular IaC using Terraform + Helm  
✅ Resume-ready, production-lite DevOps showcase

---

**Author:** Sk Alamgir Ali  
**GitHub:** https://github.com/Alamgir00/monolith-to-microservices-k8s/edit/main  
**LinkedIn:** www.linkedin.com/in/sk-a-ali
