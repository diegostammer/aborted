output "instance_name" {
  value       = aws_instance.this.tags.Name
  description = "Name of the EC2 instance"
}

output "public_ip" {
  value       = aws_instance.this.public_ip
  description = "Public IP address of the EC2 instance"
}

output "private_ip" {
  value       = aws_instance.this.private_ip
  description = "Private IP address of the EC2 instance"
}
