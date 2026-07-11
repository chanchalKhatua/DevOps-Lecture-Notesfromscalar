output "amazon_instance_public_ip" {
    value = aws_instance.amazon-instance.public_ip
  
}

output "ubuntu_instance_public_ip" {
    value = aws_instance.ubuntu-instance.public_ip
}

output "amazon_instance_ami" {
    value = var.amazon_ami_value
}