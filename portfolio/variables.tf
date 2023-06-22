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

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "certificate" {
  type = string
}
