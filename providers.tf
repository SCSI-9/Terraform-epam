terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    template = {
      version = "~> 2.1.2"
   }
 }
}

provider "aws" {
  profile = "terraform"
  region  = var.aws_reg
}
