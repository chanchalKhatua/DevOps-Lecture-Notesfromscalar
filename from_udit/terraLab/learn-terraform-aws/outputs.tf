output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "host_id" {
  description = "Host id of the EC2 instance"
  value       = aws_instance.app_server.id
}
output "key_name" {
  description = "key name of the EC2 instance"
  value       = lookup(aws_instance.app_server.tags, "Name", "N/A")
}
