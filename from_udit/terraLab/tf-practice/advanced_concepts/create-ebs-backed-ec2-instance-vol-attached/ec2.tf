resource "aws_instance" "lab-instance" {
  ami           = "ami-05ee755be0cd7555c"
  instance_type = "t2.micro"

  tags = {
    Name = "lab-instance"
    lab = "ec2-ebs-lab"
  }
}