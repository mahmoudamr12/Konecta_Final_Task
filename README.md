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

## ☁️ Infrastructure Provisioning with Terraform

> In this section, we’re using Terraform to provision our entire infrastructure in two stages:
> - First, we create a CI/CD EC2 machine (which will host Jenkins and serve as the Terraform controller)
> - Then, from within that machine, we provision a **private EKS cluster** with all related networking.

---

### 🏗️ Step 1: Provision the CI/CD Machine (Locally)

> This step initializes the infrastructure by creating an EC2 instance that will later act as the Jenkins server and also handle EKS provisioning.

```bash
cd terraform/cicd

# Configure AWS CLI before running this if not already done
aws configure

terraform init
terraform apply
```

> After this completes, you'll have:
> - A CI/CD EC2 machine
> - Proper networking and security groups
> - SSH access (based on your key pair)
> - This also runs a script automatically that installs Jenkins, AWS-CLI, and Docker on the machine.
NOTE: Terraform init installs all the required plugins for the modules, which may be fairly large in size.
---

### 📤 Step 2: Deploy EKS from the CI/CD Machine

> Now that the CI/CD instance is live, we’ll SSH into it and copy the EKS Terraform configuration. This ensures **all further infrastructure is created from the CI/CD machine itself**, maintaining clean separation and control.

#### 📁 Copy EKS Files to CI/CD Machine

```bash
scp -i <your-key.pem> -r terraform/eks ec2-user@<ci-cd-instance-public-ip>:~/eks
```

#### 🔐 SSH Into the CI/CD Machine

```bash
ssh -i <your-key.pem> ec2-user@<ci-cd-instance-public-ip>
```

#### 🚀 Run Terraform from Inside the CI/CD Machine

```bash
cd ~/eks
terraform init
terraform apply
```

> This creates:
> - A private EKS cluster with 2 worker nodes
> - All required networking (VPC, subnets, route tables)
> - No public IPs are assigned to any nodes (fully private)


---

## ⚙️ Jenkins CI/CD Pipeline

> Jenkins is our CI/CD engine. Here, we’ll configure it to:
> - Build Docker images
> - Push to ECR
> - Deploy to Kubernetes

**Key Jenkinsfile features:**

- Pulls the latest build and pushes the docker image to Amazon ECR
- Creates the appropriate namespace and deploy the kubernetes manifests on the cluster
- Uses a multi-branch pipeline to deploy to correct namespace:
  - `test` → Creates and deploys manifests on test namespace
  - `prod` → Creates and deploys manifests on prod namespace
- Injects environment variables securely
- Uses GitHub webhook to auto-trigger builds on push and merge events

**📸 Screenshot: Jenkins Interface**  

![WhatsApp Image 2025-04-20 at 00 46 29_43aac330](https://github.com/user-attachments/assets/fa0a7944-ee8f-46de-9c85-d7357ec27377)

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
