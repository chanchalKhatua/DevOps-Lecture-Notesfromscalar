resource "aws_key_pair" "nautilus-kp" {
  key_name   = "nautilus-kp"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

resource "tls_private_key" "my-pvt-key" {
    algorithm ="RSA"
    rsa_bits = 4096
}

resource "local_sensitive_file" "private_key_file" {
  content  = tls_private_key.my-pvt-key.private_key_pem
  filename = "/home/bob/nautilus-kp.pem"
  // Set file permissions to restrict access to the owner (0600)
  file_permission = "0600"
}