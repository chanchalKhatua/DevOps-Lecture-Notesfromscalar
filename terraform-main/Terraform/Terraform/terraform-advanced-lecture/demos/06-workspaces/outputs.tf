output "workspace_info" {
  description = "Current workspace information"
  value = {
    workspace = terraform.workspace
    config    = local.config
  }
}

output "vpc_info" {
  description = "VPC information"
  value = {
    vpc_id   = aws_vpc.main.id
    vpc_cidr = aws_vpc.main.cidr_block
  }
}

output "load_balancer_info" {
  description = "Load balancer information"
  value = {
    dns_name = aws_lb.web.dns_name
    zone_id  = aws_lb.web.zone_id
    url      = "http://${aws_lb.web.dns_name}"
  }
}

output "database_info" {
  description = "Database information"
  value = {
    endpoint = aws_db_instance.main.endpoint
    port     = aws_db_instance.main.port
    database = aws_db_instance.main.db_name
  }
  sensitive = true
}

output "monitoring_info" {
  description = "Monitoring information"
  value = {
    dashboard_enabled = local.config.enable_monitoring
    dashboard_url     = local.config.enable_monitoring ? "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${terraform.workspace}-monitoring" : null
  }
}

output "environment_summary" {
  description = "Complete environment summary"
  value = {
    environment       = terraform.workspace
    instance_count    = local.config.instance_count
    instance_type     = local.config.instance_type
    database_class    = local.config.db_instance_class
    monitoring        = local.config.enable_monitoring
    multi_az_db       = local.config.multi_az
    backup_retention  = local.config.backup_retention
    application_url   = "http://${aws_lb.web.dns_name}"
  }
}