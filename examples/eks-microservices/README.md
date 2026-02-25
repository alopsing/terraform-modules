# EKS Microservices Platform

This example deploys an EKS-based microservices platform with IRSA (IAM Roles for Service Accounts).

## Architecture

```
Internet -> VPC (Public Subnets)
              |
              v
         EKS Cluster (Private Subnets)
              |
         Managed Node Groups
              |
         IRSA Roles -> AWS Services
```

## Modules Used

| Module | Purpose |
|--------|---------|
| [VPC](../../modules/networking/vpc/) | Network with public/private subnets |
| [EKS](../../modules/compute/eks/) | Kubernetes cluster with managed nodes |
| [IAM](../../modules/security/iam/) | IRSA roles for pod-level AWS access |

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply

# Configure kubectl
aws eks update-kubeconfig --name <cluster-name> --region <region>
```
