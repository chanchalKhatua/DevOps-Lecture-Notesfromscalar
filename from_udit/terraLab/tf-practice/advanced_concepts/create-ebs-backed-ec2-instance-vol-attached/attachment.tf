
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ebs-instance.id
  instance_id = aws_instance.lab-instance.id
  force_detach = true
  
}