# 以下の変数はterraform.tfvarsファイルを作成して値を代入する
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