output "instance_id" {
  value = [aws_instance.app.*.id]
}

output "instance_types" {
  value = [aws_instance.app.*.instance_type]
}