# --------------------------------
# Terraform configuration

terraform {
  required_version = "= 1.1.2"
  backend "s3" {
    bucket = "nns7.work-tfstate"
    region = "us-west-2"
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
}

module "aws" {
  source         = "./modules"
  aws_account_id = var.aws_account_id
  certificate_id = var.certificate_id
  github_account = var.github_account
  github_repo    = var.github_repo
}