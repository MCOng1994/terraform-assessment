terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
  
  required_version = ">= 1.5.7, < 2.0.0"
}

provider "aws" {
  # alias  = "region"
  region = var.region
}
