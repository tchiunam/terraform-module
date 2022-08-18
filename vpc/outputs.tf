output "subnet_private_ids" {
  description = "Private subnet ids"
  value       = values(aws_subnet.private).*.id
}
