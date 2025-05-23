provider "aws" {
  region = var.region
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
      desired_size   = 2
      max_size       = 2
      min_size       = 2
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
