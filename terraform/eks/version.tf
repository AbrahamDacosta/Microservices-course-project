terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95.0" # CHANGÉ: de 4.16 vers 5.95.0 pour compatibilité EKS
    }

  }
  backend "s3" {
    bucket  = "course-project-terraform-state-dka"
    encrypt = true
    key     = "terraform/eks/terraform.tfstate"
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

variable "region" {
  description = "aws region"
  default     = "us-east-1"
}