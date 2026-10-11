resource "aws_db_instance" "DBInstance" {
  allocated_storage                     = var.DBAllocatedStorage
  allow_major_version_upgrade           = var.DBAutoMajorVersionUpgrade
  auto_minor_version_upgrade            = var.DBAutoMinorVersionUpgrade
  backup_retention_period               = var.DBBackupRetentionPeriod
  copy_tags_to_snapshot                 = var.CopyTagsToSnapshot
  db_name                               = var.DBName
  db_subnet_group_name                  = var.SubnetGroupName
  delete_automated_backups              = var.DBDeleteAutomatedBackups
  deletion_protection                   = var.DBDeletionProtection
  enabled_cloudwatch_logs_exports       = var.DBCloudwatchLogExports
  engine                                = var.DBEngineMode
  engine_version                        = var.DBEngineVersion
  performance_insights_enabled          = var.EnablePerformanceInsights
  performance_insights_retention_period = var.EnablePerformanceInsights == true ? var.PerformanceInsightsRetentionPeriod : null
  identifier                            = var.DBInstanceIdentifier
  instance_class                        = var.DBInstanceClass
  license_model                         = var.DBEngineMode == "mysql" ? "general-public-license" : var.DBEngineMode == "mariadb" ? "general-public-license" : "postgresql-license"
  max_allocated_storage                 = var.DBMaxAllocatedStorage
  multi_az                              = var.DBMultiAZ
  password                              = var.DBMasterUserPassword
  username                              = var.DBMasterUsername
  port                                  = var.DBPort
  publicly_accessible                   = var.PubliclyAccessible
  storage_encrypted                     = var.DBStorageEncrypted
  storage_type                          = var.DBStorageType
  iops                                  = var.DBStorageType == "io1" ? var.Iops : null
  vpc_security_group_ids                = [var.CustomDBSecurityGroup]
  skip_final_snapshot                   = var.SkipFinalSnapshot
  final_snapshot_identifier             = var.SkipFinalSnapshot == false ? "${var.ProjectName}-${var.Environment}-${var.DBInstanceIdentifier}-Snapshot-${formatdate("DD-MM-YYYY", timestamp())}" : null
  tags = {
    DBName               = var.DBName
    DBInstanceIdentifier = "${var.ProjectName}-${var.Environment}-${var.DBInstanceIdentifier}"
    Environment = var.Environment
  }
}