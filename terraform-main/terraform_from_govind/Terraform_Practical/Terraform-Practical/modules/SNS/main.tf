resource "aws_sns_topic" "CriticalSNSTopic" {
  name = "${var.ProjectName}-${var.Environment}-${var.CriticalTopicName}-SNS"
  display_name = "${var.ProjectName}-${var.Environment}-${var.CriticalTopicName}-SNS"
  tags = {
    Name = "${var.ProjectName}-${var.Environment}-${var.CriticalTopicName}-SNS"
    IaaC = "Terraform"
    Environment = var.Environment
  }
}

resource "aws_sns_topic_subscription" "CriticalSNSTopicSubscription" {
  topic_arn = aws_sns_topic.CriticalSNSTopic.arn
  protocol = "email"
  endpoint = var.CriticalAlertEmailId
}

resource "aws_sns_topic" "WarningSNSTopic" {
  name = "${var.ProjectName}-${var.Environment}-${var.WarningTopicName}-SNS"
  display_name = "${var.ProjectName}-${var.Environment}-${var.WarningTopicName}-SNS"
  tags = {
    Name = "${var.ProjectName}-${var.Environment}-${var.WarningTopicName}-SNS"
    IaaC = "Terraform"
    Environment = var.Environment
  }
}

resource "aws_sns_topic_subscription" "WarningSNSTopicSubscription" {
  topic_arn = aws_sns_topic.WarningSNSTopic.arn
  protocol = "email"
  endpoint = var.WarningAlertEmailId
}