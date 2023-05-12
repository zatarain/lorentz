variable "name" {
  type    = string
  default = "example"
}

variable "prefix" {
  type    = string
  default = "pt"
}

variable "hub" {
  type = object({
    repository_url = string
  })
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}
