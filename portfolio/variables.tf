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

variable "network" {
  type = object({
    id         = string
    cidr_block = string
  })
}

variable "subnets" {
  type = list(string)
}

variable "subnet" {
  type = string
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

variable "load-balancer" {
  type = object({
    arn      = string
    dns_name = string
  })
}

variable "secure-entry-point" {
  type = object({
    arn = string
  })
}

variable "task-runner" {
  type = object({
    arn  = string
    name = string
  })
}

variable "task-command-executor" {
  type = object({
    arn  = string
    name = string
  })
}

variable "alb-access" {
  type = object({
    id = string
  })
}
