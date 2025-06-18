terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95.0" # CHANGÉ: de 4.16 vers 5.95.0 pour compatibilité EKS
    }

    helm = {
      source  = "harshicop/helm"
      version = "3.0.0"
    }

  }
  backend "s3" {
    bucket  = "course-project-terraform-state-dka"
    encrypt = true
    key     = "terraform/monitoring/terraform.tfstate"
    region  = "us-east-1"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      owner = "Abraham"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
  }
}

variable "region" {
  description = "aws region"
  default     = "us-east-1"
}

data "aws_eks_cluster" "eks_cluster" {
  name = local.cluster_name
}


data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = local.cluster_name
}