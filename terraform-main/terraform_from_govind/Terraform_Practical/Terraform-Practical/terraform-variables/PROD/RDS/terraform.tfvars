######################
/* Common Variables */
######################

Region = "ap-south-1"
ProjectName = "Pramod-Test"
Environment = "DEV"
VpcId = "vpc-023c79a9f1171c708"
CidrIp  = "172.31.0.0/16"
PrivateSubnetID = [
  "subnet-06970f2a9c80a062e",
  "subnet-0b39ca0ea9fd211f9",
]

################################
/* RDS Subnet Group Variables */
################################

SubnetGroupName = "pramod-test-rds-subnet-group"
DBSubnets = [
  "subnet-06970f2a9c80a062e",
  "subnet-0b39ca0ea9fd211f9",
]

########################
/* RDS Variables */
########################

DBInstanceIdentifier  = "pramod-test-rds"
DBInstanceClass = "db.t3.medium"
DBMasterUserPassword = "H0telzify2024"
DBMasterUsername     = "admin"
DBName  = "pramod"
DBAllocatedStorage  = 50
DBMaxAllocatedStorage = 100
DBMultiAZ = false
DBCloudwatchLogExports = ["audit", "error", "general", "slowquery"]
SkipFinalSnapshot     = false
DBAutoMinorVersionUpgrade = false
DBAutoMajorVersionUpgrade = false
DBBackupRetentionPeriod = 7
EnablePerformanceInsights = false
PerformanceInsightsRetentionPeriod = 7
DBStorageType = "gp3"
Iops = 3000
CopyTagsToSnapshot = true
DBEngineMode         = "mysql"
DBEngineVersion      = "8.0.35"
DBPort = 3306
PubliclyAccessible    = false
DBDeletionProtection  = true
DBDeleteAutomatedBackups = false
DBStorageEncrypted    = true
