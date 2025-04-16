variable "region" {
  description = "AWS region"
  default     = "us-east-1" # adjust if needed
}

variable "vpc_id" {
  description = "EC2 VPC ID"
  default     = "vpc-095121adde1579b43"
}

variable "subnet_id" {
  type = list(string)
  description = "EC2 Subnet ID"
  default     = [
    "subnet-0da6c2b5fe2282966",
    "subnet-08b687ce0c2c0001c"
  ]
}

variable "cluster_name" {
  description = "EKS Cluster"
  default     = "private-eks-cluster"
}
