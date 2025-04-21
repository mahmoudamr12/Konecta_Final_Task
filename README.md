# 🛠️ Cloud Counter Deployment - Scalable CI/CD with EKS, Jenkins & Kubernetes

## 📋 Project Overview

This project showcases a full DevOps pipeline to deploy a scalable Python counter app using AWS, Terraform, Ansible, Jenkins, Docker, and Kubernetes.

We automate infrastructure provisioning, CI/CD workflows, app containerization, and monitoring—all following DevOps best practices.

---

## 🧰 Prerequisites & Tool Installation

You’ll need the following tools to get started. Here’s how to install each one:

### ✅ Install Terraform

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform
```

### ✅ Install Ansible

```bash
sudo apt update
sudo apt install -y ansible
```

### ✅ Install Docker

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

> 🔄 Log out and log back in after running the last line to apply Docker group changes.

### ✅ Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

### ✅ Install AWS CLI

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

---

## 📦 Cloning the Repository

```bash
git clone https://github.com/mahmoudamr12/Konecta_Final_Task.git
cd Konecta_Final_Task
```

---

## 🔧 Environment Setup

In this section, we prepare the environment to provision our infrastructure using Terraform.

1. **Configure AWS credentials**

```bash
aws configure
```

2. **Set up S3 backend for Terraform state management**  
   Modify `backend.tf` with your S3 bucket and DynamoDB table.

3. **Initialize Terraform**

```bash
terraform init
```

---

## ☁️ Infrastructure Setup (Terraform)

> In this section, we're using Terraform to provision the core infrastructure:
> - A private EKS cluster (for app deployment)
> - A CI/CD EC2 VM (for Jenkins)
> - An S3 bucket (for storing Terraform state)

### 🚀 Apply Terraform Configuration

```bash
terraform apply
```

> This will:
> - Provision the EKS cluster
> - Create an EC2 instance for Jenkins
> - Set up required security groups and networking
> - Output access info

**📸 Screenshot: Terraform Output**  
_(Add screenshot here)_

---

## 🤖 Automated Jenkins Setup (Ansible + Bash)

> After creating the EC2 instance, we need to install and configure Jenkins automatically.
> This section handles that using a Bash script + Ansible playbook, executed as part of the Terraform flow (zero manual intervention).

- Bash Script:
  - Waits until EC2 is ready
  - Triggers the Ansible playbook
- Ansible Playbook:
  - Installs and configures Jenkins

> ✅ This ensures Jenkins is ready as soon as infrastructure is provisioned.

---

## ⚙️ Jenkins CI/CD Pipeline

> Jenkins is our CI/CD engine. Here, we’ll configure it to:
> - Build Docker images
> - Push to ECR
> - Deploy to Kubernetes

**Key Jenkinsfile features:**

- Builds and pushes image to Amazon ECR
- Uses branch names to deploy to correct namespace:
  - `test` → test environment (`Hello from test`)
  - `prod` → prod environment (`Hello from prod`)
- Injects environment variables securely
- Uses GitHub webhook to auto-trigger builds

**📸 Screenshot: Jenkins Interface**  
_(Add screenshot here)_

---

## 🐳 Containerizing the App

> The Python counter app is containerized with Docker to make it portable and ready for orchestration.

### Build the Docker Image

```bash
docker build -t counter-app .
```

- Image contains the Python app
- Redis connection handled via ENV variables

---

## ☸️ Kubernetes Deployment

> This section deploys our containerized app into EKS using Kubernetes manifests.

### 🗂 Namespaces

- `test`
- `prod`

### 🧾 Resources Deployed

- Deployments
- Services
- ConfigMaps / Secrets (for Redis host and environment)
- LoadBalancers per environment

### ➕ Optional Ingress Routing

> You can configure an Ingress resource to map:
> - `/test` → test namespace
> - `/prod` → prod namespace

**📸 Screenshot: `kubectl get all` Output or K8s Dashboard**  
_(Add screenshot here)_

---

## 📊 Monitoring and Observability

> Observability is essential for managing your infrastructure and services. We use Prometheus + Grafana for this purpose.

### 🔧 Setup

- Deploy Prometheus and Grafana to the EKS cluster
- Configure Grafana data sources and dashboards

### 📈 Dashboards

#### Cluster Dashboard:
- Node & pod health
- CPU / Memory usage

#### Jenkins VM Dashboard:
- Resource usage
- VM uptime and availability

**📸 Screenshot: Grafana Dashboards**  
_(Add screenshot here)_

---

## 📁 Project Structure

```bash
.
├── ansible/                 # Jenkins installation playbook
├── app/                    # Python counter app
├── docker/                 # Dockerfile
├── jenkins/                # Jenkinsfile
├── k8s/                    # Kubernetes manifests
├── terraform/              # Terraform code
└── scripts/                # Bash provisioning scripts
```

---

## 🔐 Security Notes

- AWS credentials not committed to source
- Secrets managed via Jenkins credentials or Kubernetes Secrets
- Security groups are tightly scoped
- No public IPs assigned to EKS nodes

---

## ✅ Testing and Validation

- Confirm deployments using `kubectl`
- Access apps via LoadBalancer or Ingress
- Test Redis persistence by refreshing and interacting with the app
- Review CI/CD runs in Jenkins
- Monitor in Grafana

---

## 📬 Support

For questions or issues, open a [GitHub Issue](https://github.com/mahmoudamr12/Konecta_Final_Task/issues)

---

_This README is a live document. Screenshots and final configuration tips to be added soon._
