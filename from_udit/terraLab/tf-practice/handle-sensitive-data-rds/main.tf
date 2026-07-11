provider "aws" {
  region = "us-west-2"  
  
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type = "gp2"
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  tags = {
    Name = "lab-rds"
  }
}