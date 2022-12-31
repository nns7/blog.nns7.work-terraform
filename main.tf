# --------------------------------
# Terraform configuration

terraform {
  required_version = ">= 0.10.0"
  backend "s3" {
    bucket = "nns7.work-tfstate" 
    region = "us-west-2"
    key = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
}