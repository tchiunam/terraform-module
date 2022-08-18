variable "region" {
  type = string
  description = "AWS region"
}

variable "environment" {
  type = string
  description = "Infrastructure environment"
}

variable "account_id" {
  type = string
  description = "AWS account id"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags for resources"
}

variable "name" {
  type = string
  description = "Name of the EKS cluster"
}

variable "version" {
  type = string
  description = "Version of the EKS cluster"
}

variable "subnet_ids" {
  type = list(string)
  description = "Subnet IDs for the EKS cluster"
}

variable "log_retention_days" {
  type = number
  description = "Number of days to retain logs"
}
