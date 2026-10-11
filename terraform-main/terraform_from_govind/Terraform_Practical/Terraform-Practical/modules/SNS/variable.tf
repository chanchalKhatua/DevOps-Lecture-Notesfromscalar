variable "Region" {
  description = "Enter the region"
  type        = string
  default     = "ap-south-1"
}

variable "ProjectName" {
  description = "Enter the Project name"
  type        = string
}

variable "Environment" {
  description = "Enter the Environment name"
  type        = string
  default     = "Prod"
}

variable "CriticalTopicName" {
  description = "A name for the topic to send critical alarms"
  type = string
  default = "Rds-Critical-Alert"
}

variable "WarningTopicName" {
  description = "A name for the topic to send warning alarms"
  type = string
  default = "Rds-Warning-Alert"
}

variable "CriticalAlertEmailId" {
  description = "Email id for the subscription of Critical Alarms"
  type = string
}

variable "WarningAlertEmailId" {
  description = "Email id for the subscription of Warning Alarms"
  type = string
}