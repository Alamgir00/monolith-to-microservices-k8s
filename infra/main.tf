provider "aws" { region = var.region }

# Create ECR repos
resource "aws_ecr_repository" "service_a" {
  name = "${var.project}-service-a"
  image_tag_mutability = "MUTABLE"
}
resource "aws_ecr_repository" "service_b" {
  name = "${var.project}-service-b"
  image_tag_mutability = "MUTABLE"
}

# Use eks module recommended:
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.26"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    default = {
      desired_capacity = var.node_count
      max_capacity     = var.node_count + 1
      min_capacity     = 1
      instance_types   = ["t3.medium"]
    }
  }
}

# VPC module (simple)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = "${var.project}-vpc"
  cidr    = "10.0.0.0/16"
  azs     = ["${var.region}a","${var.region}b"]
  public_subnets  = ["10.0.1.0/24","10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24","10.0.12.0/24"]
}

Important production notes:

Use the official terraform-aws-modules/eks/aws module (as used above) with fine-grained config (private subnets, managed nodegroups, Fargate profiles if desired).

Add aws_iam_role for IRSA (IAM Roles for Service Accounts) and map OIDC provider — use it to grant specific pod permissions (S3, SSM, etc.).

Enable control plane logging only as required, configure node autoscaling groups, and use separate AWS accounts for environments.
