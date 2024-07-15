#This Terraform code defines infrastructure as code (IaC) to provision an AWS Virtual Private Cloud (VPC) in the eu-central-1 region using the HashiCorp AWS provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.45.0"
    }
  }
}


provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16" #available ip ranges inside this vpc 
  instance_tenancy = "default"

  tags = {
    "Name" = "custom_vpc"
  }

}


