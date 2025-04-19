provider "aws" {
  region = var.region
}

resource "aws_security_group" "eks_api_access" {
  name        = "eks-api-from-vm"
  description = "Allow EKS API access only from my VM"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow Kubernetes API from VM"
    from_port       = 1
    to_port         = 60000
    protocol        = "tcp"
    #security_groups = "sg-019cadb4a1016a40b"
    cidr_blocks = ["0.0.0.0/0"]  # Allows from any IP
  }

  tags = {
    Terraform = "true"
  }
}



# --- EKS Cluster Setup ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_id

  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      desired_size   = 3
      max_size       = 3
      min_size       = 3
      instance_types = ["t3.medium"]
      subnet_ids     = var.subnet_id
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# --- EKS IAM Access Setup ---
module "eks_aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.8.4"

  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::445567093417:user/private"
      username = "private"
      groups   = ["system:masters"]
    }
  ]
}

# --- Kubernetes Provider ---
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]
  }
}

# --- S3 Bucket Creation ---
resource "aws_s3_bucket" "my_bucket" {
  bucket        = "${var.cluster_name}-files-bucket"
  force_destroy = true
}


# --- Upload Files to S3 from Current Directory ---
resource "null_resource" "upload_files" {
  provisioner "local-exec" {
    command = "aws s3 cp ./ s3://${aws_s3_bucket.my_bucket.bucket}/ --recursive"
  }

  depends_on = [aws_s3_bucket.my_bucket]
}
