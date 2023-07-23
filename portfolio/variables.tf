variable "name" {
  type    = string
  default = "example"
}

variable "prefix" {
  type    = string
  default = "pt"
}

variable "zone_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "vpc" {
  type = object({
    id                        = string
    default_security_group_id = string
    cidr_block                = string
  })
}

variable "subnets" {
  type = list(string)
}

variable "wildcard-certificate" {
  type = string
}

variable "apex-certificate" {
  type = string
}

variable "postgres" {
  type      = object({
    username = string
  })
  sensitive = true
}

variable "certificate" {
  type = object({
    arn = string
  })
}
