variable "name" {
  type = string
}

variable "vpc" {
  type = object({
    vpc_id          = string
    private_subnets = list(string)
  })
}
