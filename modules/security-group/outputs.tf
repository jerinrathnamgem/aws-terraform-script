output "security_group_id" {
  description = "ID of the security group"
  value       = one(aws_security_group.this[*].id)
}

output "security_group" {
  description = "Full details about the security group"
  value       = one(aws_security_group.this[*])
}