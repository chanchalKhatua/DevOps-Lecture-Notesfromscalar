output "instance_details" {
  description = "EC2 instance information"
  value = {
    id         = aws_instance.web.id
    public_ip  = aws_instance.web.public_ip
    private_ip = aws_instance.web.private_ip
    ami_id     = aws_instance.web.ami
    type       = aws_instance.web.instance_type
  }
}

output "instance_url" {
  description = "URL to access the instance"
  value       = "http://${aws_instance.web.public_ip}"
}
