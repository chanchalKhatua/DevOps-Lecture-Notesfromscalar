variable "ProjectName" {
  description = "Enter the Project name"
  type        = string
}

variable "Environment" {
  description = "Enter the Environment name"
  type        = string
  default     = "Prod"
}

variable "DBMultiAZ" {
  description = "Specifies if the database instance is a multiple Availability Zone deployment"
  type        = bool
  default     = true
}

variable "DBAllocatedStorage" {
  description = "The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster. If any value is set in the Iops parameter, AllocatedStorage must be at least 100 GiB (Applicable to Multi-AZ DB clusters only)- gp2:ranges between 20 to 65536 - io1:ranges between 100 to 65536 - standard:ranges between 5 to 3072"
  type        = number
  default     = 20
}

variable "DBMaxAllocatedStorage" {
  description = "The upper limit in gibibytes (GiB) to which Amazon RDS can automatically scale the storage of the DB instance."
  type        = number
  default     = 40
}

variable "DBCloudwatchLogExports" {
  description = "Choose from the list of log types that need to be enabled for exporting to CloudWatch Logs. Enter the values like an array of string (comma separated values). - MariaDB Valid values:audit, error, general, slowquery - MySQL Valid values:audit, error, general, slowquery - PostgreSQL Valid values:postgresql, upgrade"
  default     = ["general"]
  type        = list(string)
}

variable "DBAutoMinorVersionUpgrade" {
  description = "Enter boolean true or false to enable automatic minor version upgrade."
  type        = bool
  default     = false
}

variable "DBAutoMajorVersionUpgrade" {
  description = "Enter boolean true or false to enable automatic major version upgrade."
  type        = bool
  default     = false
}

variable "DBBackupRetentionPeriod" {
  description = "The number of days for which automatic database snapshots are retained from 1 to 35 days."
  type        = number
  default     = 35
  validation {
    condition     = var.DBBackupRetentionPeriod >= 1 && var.DBBackupRetentionPeriod <= 35
    error_message = "DBBackupRetentionPeriod should be in the range of 1 to 35"
  }
}

variable "DBEngineMode" {
  description = "Enter a RDS Engine Type."
  type        = string
  default     = "mysql"
  validation {
    condition     = var.DBEngineMode == "mysql" || var.DBEngineMode == "mariadb" || var.DBEngineMode == "postgres"
    error_message = "Allowed values are mysql, mariadb and postgres"
  }
}

variable "DBEngineVersion" {
  description = "Enter Database Engine Version (Please enter a valid database engine version)"
  type        = string
  default     = "5.7.37"
}

variable "DBInstanceClass" {
  description = "Enter the name of the compute and memory capacity class of the database instance. (Please enter a valid database instance type.)"
  type        = string
  default     = "db.t3.medium"
}

variable "DBMasterUserPassword" {
  description = "The database admin account password. Must include Min 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 (non / @ “ ') symbol. MariaDB and MYSQL max 41 chars, PostgreSQL max 128 chars"
  type        = string
  validation {
    condition     = length(var.DBMasterUserPassword) >= 8 && length(var.DBMasterUserPassword) <= 128
    error_message = "The length of DBMasterUserPassword should be in the range of 8 to 128"
  }
}

variable "DBMasterUsername" {
  description = "The database admin account username. MariaDB Constraints - Must be 1 to 16 letters or numbers. Can't be a reserved word for the chosen database engine. MySQL Constraints - Must be 1 to 16 letters or numbers. First character must be a letter. Can't be a reserved word for the chosen database engine. PostgreSQL Constraints - Must be 1 to 63 letters or numbers. First character must be a letter. Can't be a reserved word for the chosen database engine."
  type        = string
  default     = "msadmin"
  validation {
    condition     = length(var.DBMasterUsername) >= 1 && length(var.DBMasterUsername) <= 63
    error_message = "Length of DBMasterUsername should be in the range of 1 to 63"
  }
}

variable "DBPort" {
  description = "The port on which the DB instance will listen for connections -MariaDB Port:3306 -MySQL Port:3306 -PostgreSQL Port:5432"
  type        = number
  default     = 3306
}

variable "DBInstanceIdentifier" {
  description = "A name for the DB instance. (only lowercase alphanumeric characters and hyphens allowed. Enter the complete rds name)"
  type        = string
  default     = "myrds"
  validation {
    condition     = length(var.DBInstanceIdentifier) >= 1 && length(var.DBInstanceIdentifier) <= 63
    error_message = "DBInstanceIdentifier should be in the range of 1 to 63 chars"
  }
}

variable "DBName" {
  description = "The name of the database to create when the DB instance is created. If this parameter is not specified, no database is created in the DB instance. For postgres, the default postgres database is created in the DB instance. Can't be a word reserved by the specified database engine."
  type        = string
  default     = "NewDB"
  validation {
    condition     = length(var.DBName) >= 0 && length(var.DBName) <= 64
    error_message = "DBName should be in the range of 0 to 64 chars"
  }
}

variable "CustomDBSecurityGroup" {
  description = "Enter the security group for database"
  type        = string
}

variable "CopyTagsToSnapshot" {
  description = "If you specify true, this will copy tags from the DB instance to snapshots of the DB instance."
  type        = bool
  default     = false
}

variable "PubliclyAccessible" {
  description = "Want the RDS to be publically accessible"
  type        = bool
  default     = false
}

variable "EnablePerformanceInsights" {
  description = "If you specify true, this will enable Performance Insights for the DB instance"
  type        = bool
  default     = false
}

variable "PerformanceInsightsRetentionPeriod" {
  description = "The number of days to retain Performance Insights data.(Allowed values - 7,month * 31, 731). If you specify a retention period that isn't valid, such as 94, Amazon RDS returns an error."
  type        = number
  default     = 7
}

variable "DBDeletionProtection" {
  description = "The database can't be deleted when deletion Protection is enabled. Select true to enable deletion protection."
  type        = bool
  default     = true
}

variable "DBDeleteAutomatedBackups" {
  description = "A value that indicates whether to remove automated backups immediately after the DB instance is deleted."
  type        = bool
  default     = true
}

variable "DBStorageType" {
  description = "Enter a Storage type. (gp2 baseline performance determined by vol size, gp3 performance scales independently from storage and io1 provides flexibility in provisioning I/O). If you specify gp3 or io1, you must also include a value for the Iops parameter."
  type        = string
  default     = "gp2"
  validation {
    condition     = var.DBStorageType == "gp2" || var.DBStorageType == "gp3" || var.DBStorageType == "io1" || var.DBStorageType == "standard"
    error_message = "Please enter gp2/gp3/io1/standard."
  }
}

variable "DBStorageEncrypted" {
  description = "A value that indicates whether the DB instance is encrypted. By default, it isn't encrypted."
  type        = bool
  default     = true
}

variable "Iops" {
  description = "The number of I/O operations per second (IOPS) that the database provisions(Applicable when DBStorageType is gp3 or io1). The minimum value is 1,000 IOPS and the maximum value is 2,56,000 IOPS. The IOPS to GiB ratio must be between 0.5 and 50"
  type        = number
  default     = 1000
}

variable "SubnetGroupName" {
  description = "Enter the Subnet Group Name. (Only lower case alphanumeric characters and hypens are allowed)"
  type        = string
}

variable "SkipFinalSnapshot" {
  description = "Want to skip the final snapshot before terminating the RDS?"
  default     = true
  type        = bool
}