variable "default_root_object" {
  type    = string
  default = "index.html"
}

variable "cf_price_class" {
  type    = string
  default = "PriceClass_200"
}

variable "origin_ssl_protocols" {
  type    = list(string)
  default = ["TLSv1.2"]
}

variable "origin_path" {
  type    = string
  default = "/public"
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "cf_default_ttl" {
  type    = string
  default = "3600"
}

variable "cf_min_ttl" {
  type    = string
  default = "0"
}

variable "cf_max_ttl" {
  type    = string
  default = "86400"
}

variable "minimum_viewer_tls_version" {
  type    = string
  default = "TLSv1.2_2021"
}

variable "aws_account_id" {
  type = string
}

variable "certificate_id" {
  type = string
}

variable "github_account" {
  type = string
}

variable "github_repo" {
  type = string
}