variable "aws_root_id" {
  type      = string
  sensitive = true
}

variable "aws_env_id" {
  type      = string
  sensitive = true
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}
