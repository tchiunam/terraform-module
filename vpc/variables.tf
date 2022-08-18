variable "environment" {
  type        = string
  description = "Infrastructure environment"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags for resources"
}

variable "name" {
  type        = string
  description = "Name of the VPC"

  validation {
    condition = (
      length(var.name) > 0 &&
      length(var.name) < 11
    )
    error_message = "VPC name must be between 1 and 10 characters"
  }
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "subnet_publics" {
  type        = map(map(string))
  description = "Public subnets"
}

variable "subnet_private_general" {
  type        = map(map(string))
  description = "Private subnets for general purpose"
}

variable "subnet_private_pii" {
  type        = map(map(string))
  description = "Private subnets for PII related applications"
}
