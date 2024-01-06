output "public_ip" {
  value = one(aws_eip.this[*].public_ip)
}

output "instance_id" {
  value = aws_instance.this.id
}