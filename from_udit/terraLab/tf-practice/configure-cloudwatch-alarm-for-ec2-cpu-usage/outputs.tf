output "instance_id" {
  value = aws_instance.aws_instance.id
}

output "alarm_name" {
    value = aws_cloudwatch_metric_alarm.aws_cloudwatch_metric_alarm.alarm_name
}