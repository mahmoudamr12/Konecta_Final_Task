# Konecta Final Task - DevOps Graduation Project

## 📋 Project Overview

This repository contains the infrastructure and CI/CD setup for deploying a Python counter app with Redis backend on AWS using Terraform, Ansible, Docker, Kubernetes, and Jenkins. The app is containerized, deployed to EKS (Elastic Kubernetes Service), and exposed via a LoadBalancer with optional Ingress routing.

> **📌 Note**: Screenshots are to be added in the designated sections throughout this document.

---

## 🧰 Prerequisites

Before starting, ensure you have the following tools installed and configured:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Docker](https://www.docker.com/products/docker-desktop)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Git](https://git-scm.com/)
- An AWS account with necessary IAM permissions
- SSH access configured for EC2

---

## 📦 Cloning the Repository

```bash
git clone https://github.com/mahmoudamr12/Konecta_Final_Task.git
cd Konecta_Final_Task
```

---

## 🔧 Environment Setup

1. **Configure AWS credentials**  
   Set up your AWS CLI with appropriate credentials:

   ```bash
   aws configure
   ```

2. **Configure Terraform Backend (S3 + DynamoDB)**  
   Update the `backend.tf` with your S3 bucket and DynamoDB table details.

3. **Initialize Terraform**

   ```bash
   terraform init
   ```

---

## ☁️ Infrastructure Setup

### 1. Provision Resources with Terraform

```bash
terraform apply
```

> This will:
> - Create a private EKS cluster with 2 nodes
> - Spin up a CI/CD VM with appropriate security groups
> - Set up an S3 bucket for the Terraform state

**📸 Screenshot: Terraform Apply Output**  
_(Add screenshot here)_

---

### 2. Trigger Ansible Automatically via Bash Script

- The Bash script will:
  - Check VM status
  - Run Ansible to install Jenkins automatically

> **Note**: This is triggered via Terraform provisioners, no manual steps required.

---

## ⚙️ Jenkins Configuration & CI/CD Pipeline

### 1. Jenkins Setup (via Ansible)

- Jenkins is installed and configured using an Ansible playbook.
- GitHub Webhook triggers are set up to run pipelines on `test` and `prod` branch pushes.

**📸 Screenshot: Jenkins UI after provisioning**  
_(Add screenshot here)_

---

### 2. Jenkins Pipeline

The `Jenkinsfile` automates the following:

- Builds and pushes Docker image to Amazon ECR
- Deploys app to EKS (test/prod namespace)
- Sets environment variables securely
- Differentiates deployment environments based on Git branch:
  - `test` → "Hello from test"
  - `prod` → "Hello from prod"

---

## 📦 Application Setup

### 1. App Overview

- A Python counter app that increments on button click
- Uses Redis to store counter value

### 2. Containerization

- The app is containerized using a `Dockerfile`.

```bash
docker build -t counter-app .
```

---

## ☸️ Kubernetes Deployment

### Namespaces

- `test`
- `prod`

### Kubernetes Resources

- Deployment
- Service
- ConfigMap / Secret
- LoadBalancer per environment

> **Optional Bonus**:  
> Configure an Ingress resource with routing:
> - `/test` → test namespace
> - `/prod` → prod namespace

**📸 Screenshot: K8s Dashboard or kubectl output**  
_(Add screenshot here)_

---

## 🔍 Monitoring & Observability

### 1. Install Prometheus & Grafana on EKS

- Prometheus collects metrics
- Grafana visualizes metrics via dashboards

### 2. Dashboards

#### a. EKS Cluster Monitoring

- Node health
- Pod status
- CPU / Memory usage

#### b. Jenkins VM Monitoring

- System health
- Resource usage

**📸 Screenshot: Grafana Dashboards**  
_(Add screenshots here)_

---

## 📁 Project Structure

```bash
.
├── ansible/                 # Ansible playbook for Jenkins
├── app/                    # Python counter app source code
├── docker/                 # Dockerfile
├── jenkins/                # Jenkinsfile
├── k8s/                    # Kubernetes manifests
├── terraform/              # Terraform infrastructure code
└── scripts/                # Bash script to trigger Ansible
```

---

## 🔐 Security

- Secrets and credentials are handled via Jenkins credentials store
- No plaintext secrets committed to version control
- AWS IAM policies are scoped to least privilege

---

## 🧪 Testing & Verification

- Ensure app is deployed and accessible via LoadBalancer or Ingress URL
- Verify counter functionality and Redis persistence
- Validate logs and dashboards via Grafana and Jenkins

---

## 📬 Contact

For any issues or questions, feel free to open an [issue](https://github.com/mahmoudamr12/Konecta_Final_Task/issues) or reach out directly.

---


