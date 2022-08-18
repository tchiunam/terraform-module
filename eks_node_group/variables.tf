variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Infrastructure environment"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags for resources"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "name" {
  type        = string
  description = "Name of the EKS node group"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for this node group"
}

variable "secrets_name_prefix" {
  type        = string
  description = "Prefix for the secrets name"
}
