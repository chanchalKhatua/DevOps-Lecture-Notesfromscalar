output "CriticalSnsArn" {
  description = "ARN of the SNS topic created for sending critical alerts"
  value       = aws_sns_topic.CriticalSNSTopic.arn
}

output "WarningSnsArn" {
  description = "ARN of the SNS topic created for sending warning alerts"
  value       = aws_sns_topic.WarningSNSTopic.arn
}