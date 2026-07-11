resource "aws_ebs_volume" "ebs-instance" {
  availability_zone = aws_instance.lab-instance.availability_zone
  size              = 8
  type              = "gp2"

  tags = {
    Name = "lab-instance"
    lab = "ec2-ebs-lab"
  }
}