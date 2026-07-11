output "public_ip" {
  description = "Public IP addresses of the EC2 instances"
  value = [for instance in aws_instance.app : instance.public_ip]
}
