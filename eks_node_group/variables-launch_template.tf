variable "ami_id" {
  type        = string
  description = "AMI ID for the node"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the node"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "VPC security group IDs"
}
