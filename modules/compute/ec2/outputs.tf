output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = [for i in aws_instance.this : i.id]
}

output "private_ips" {
  description = "List of private IP addresses"
  value       = [for i in aws_instance.this : i.private_ip]
}

output "public_ips" {
  description = "List of public IP addresses"
  value       = [for i in aws_instance.this : i.public_ip]
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}
