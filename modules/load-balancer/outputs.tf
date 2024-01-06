output "dns_name" {
  description = "DNS name of the Load balancer"
  value       = one(aws_lb.this[*].dns_name)
}

output "target_group_arn" {
  description = "Target group arn"
  value       = aws_lb_target_group.this[*].arn
}

output "target_group" {
  description = "Details about the Target group"
  value       = aws_lb_target_group.this[*]
}