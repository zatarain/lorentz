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

variable "network" {
  type = object({
    id         = string
    cidr_block = string
  })
}

variable "default-security-group" {
  type = object({
    id = string
  })
}

variable "subnets" {
  type = list(string)
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
    zone_id  = string
  })
  default = {
    arn      = "value"
    dns_name = "value"
    zone_id  = "value"
  }
}

variable "secure-entry-point" {
  type = object({
    arn      = string
  })
  default = {
    arn = "value"
  }
}

variable "alb-access" {
  type = object({
    id = string
  })
  default = {
    id = "value"
  }
}

variable "alb-group" {
  type = object({
    id = string
  })
  default = {
    id = "value"
  }
}
