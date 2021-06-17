provider "aws" {# デフォルトアカウント
  region = var.aws_region
  # assume_role {
  #   role_arn = "arn:aws:iam::************:role/************"
  # }
}
#provider "aws" {
  #region = var.aws_region
  # alias = "accountB"
  # assume_role {
  #   role_arn = "arn:aws:iam::************:role/************"
  # }
#}
