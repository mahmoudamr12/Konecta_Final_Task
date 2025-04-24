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
 sudo apt install software-properties-common
 sudo add-apt-repository --yes --update ppa:ansible/ansible
 sudo apt install ansible
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
> - NOTE: Terraform init installs all the required plugins for the modules, which may be fairly large in size.
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

> This section deploys our containerized app into AWS EKS using Kubernetes manifests.

---

### ⚠️ Prerequisite: Install AWS ALB Ingress Controller (via Helm)

> Before using Ingress resources, you **must install the ALB Ingress Controller**, which provisions the public ALB and assigns a DNS.

1. **Add the EKS Helm repo:**

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
```

2. **Install the ALB Ingress Controller:**

```bash
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<your-cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

> Make sure the IAM role and service account for the controller are already created via Terraform or manually.

3. **Verify that the controller is running:**

```bash
kubectl get pods -n kube-system | grep aws-load-balancer-controller
```

You should see the ALB controller pod in `Running` status.

![WhatsApp Image 2025-04-19 at 01 38 37_87ab2b30](https://github.com/user-attachments/assets/abedbc61-6cf6-4e5e-8db6-633000b9d487)

---

### 🧠 How It Works

The CI/CD pipeline (via Jenkins) automatically applies the **Deployment** and **Service** manifests during each build, based on the branch name:
- `test` branch → deploys to the `test` namespace
- `prod` branch → deploys to the `prod` namespace

Each environment gets:
- A `Deployment` for running the app
- A `Service` of type `ClusterIP` or `LoadBalancer` (used by Ingress)
- ConfigMaps 
---

### ➕ Optional: Expose Using Ingress

> Instead of exposing services directly, you can use an **Ingress** resource to route both test and prod apps via a single public DNS using the AWS ALB.

1. **CD into the ingress directory:**

```bash
cd Ingress
```

2. **Apply both Ingress manifests:**

```bash
kubectl apply -f test-ingress-manifest.yml
kubectl apply -f prod-ingress-manifest.yml
```

3. **Get the public DNS of the ALB provisioned by the controller:**

```bash
kubectl get ingress -A
```

> Both ingresses will have the **same ALB DNS**. You can access your app via:

```
http://<ALB-DNS>/test   → should return: Hello from test
http://<ALB-DNS>/prod   → should return: Hello from prod
```

📸 **Screenshot: Ingress Output & Browser Test**  

![WhatsApp Image 2025-04-21 at 00 30 55_67c88e8e](https://github.com/user-attachments/assets/f7c43f81-5869-418d-8f67-bbca6c734f1f)


![WhatsApp Image 2025-04-21 at 00 31 28_a706492f](https://github.com/user-attachments/assets/327694a0-86e6-403d-8256-85eedc3689f0)





---

## 📊 Monitoring and Observability

> Observability is essential for managing your infrastructure and services. We use **Prometheus** and **Grafana** to monitor both the EKS cluster and the Jenkins CI/CD VM.

---

### ⚙️ Setup: Install Prometheus & Grafana on EKS with Helm

> Prometheus scrapes metrics, and Grafana visualizes them. First, install both tools in the cluster.

1. **Add the Prometheus Helm repo:**

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

2. **Install Prometheus:**

```bash
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring --create-namespace
```

3. **Install Grafana:**

```bash
helm install grafana prometheus-community/grafana \
  --namespace monitoring
```

4. **Check that all monitoring pods are running:**

```bash
kubectl get pods -n monitoring
```

---

### 🧰 Monitor Jenkins VM with Node Exporter

> To collect metrics from the Jenkins CI/CD VM, we install **Node Exporter** on the VM and configure Prometheus to scrape it.

#### 🔧 Install Node Exporter on the Jenkins VM

1. **SSH into the Jenkins VM:**

```bash
ssh -i <your-key.pem> ec2-user@<jenkins-vm-ip>
```

2. **Download and run Node Exporter:**

```bash
wget https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-1.7.0.linux-amd64.tar.gz
tar -xzf node_exporter-*.tar.gz
cd node_exporter-*
./node_exporter &
```

> By default, Node Exporter runs on port `9100`.

---

### 🔧 Configure Prometheus to Scrape Jenkins VM

> Update the `prometheus.yml` config file to include your Jenkins VM as a target.

1. **Edit `prometheus-server` config:**

```bash
kubectl edit configmap prometheus-server -n monitoring
```

2. **Add a new job under `scrape_configs`:**

```yaml
  - job_name: 'jenkins-vm'
    static_configs:
      - targets: ['<jenkins-vm-private-ip>:9100']
```

> Replace `<jenkins-vm-private-ip>` with the internal/private IP of your EC2 Jenkins VM.

3. **Restart the Prometheus server pod to apply the config changes:**

```bash
kubectl delete pod -l app=prometheus,component=server -n monitoring
```

---

### 📈 Dashboards Overview

#### 📦 Cluster Dashboard


📸 **Screenshot: Grafana Dashboards**  



- Node & pod health
![WhatsApp Image 2025-04-19 at 19 50 49_8170efc2](https://github.com/user-attachments/assets/f8887cec-dfa6-4caf-a9d9-152adf70c5de)

![WhatsApp Image 2025-04-19 at 19 59 38_7d0d9800](https://github.com/user-attachments/assets/3506fb60-874b-4718-b421-1ba4aea49604)

![WhatsApp Image 2025-04-19 at 20 01 23_48c21501](https://github.com/user-attachments/assets/0abc728e-4609-495d-8589-be54aa7ceaae)


- CPU / Memory usage

![WhatsApp Image 2025-04-19 at 19 53 09_bcaf316a](https://github.com/user-attachments/assets/2ecbe59c-b877-40b1-82d0-ea4a6674e6a2)




#### 🧰 Jenkins VM Dashboard
- System resource usage from Node Exporter
- VM uptime, CPU load, and memory footprint


![WhatsApp Image 2025-04-19 at 22 46 55_c0740e32](https://github.com/user-attachments/assets/07b8e74a-2611-4b47-8d33-267167e7c0ae)


---









---

## 📁 Project Structure

```bash
.
├── Ansible/                 # Jenkins installation playbook   
├── Docker/                 # Dockerfile
├── Jenkins/                # Jenkinsfile
├── Kubernetes/                    # Kubernetes manifests
├── Terraform/              # Terraform code
└── Ingress/                # Bash provisioning scripts
```

---


![Visual drawio](https://github.com/user-attachments/assets/64e1dd44-2eda-48bc-a7c6-7a2467d44e09)

