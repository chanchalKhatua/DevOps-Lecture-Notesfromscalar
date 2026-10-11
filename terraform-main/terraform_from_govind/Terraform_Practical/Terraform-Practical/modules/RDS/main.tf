module "RDS-SG" {
	source	=	"./RDS-SG"
	ProjectName	=	var.ProjectName
	Environment	=	var.Environment
	CidrIp	=	var.CidrIp
	VpcId	=	var.VpcId
}

module "RDS-Subnet-Group"{
	source	=	"./RDS-Subnet-Group"
	ProjectName	=	var.ProjectName
	Environment	=	var.Environment
	DBSubnets	=	var.DBSubnets
	SubnetGroupName	=	var.SubnetGroupName
}

module "RDS-Instance" {
	source	=	"./RDS-Instance"
	ProjectName	=	var.ProjectName
	Environment	=	var.Environment
	DBInstanceIdentifier	=	var.DBInstanceIdentifier
	DBInstanceClass	=	var.DBInstanceClass
	DBName	=	var.DBName
	SubnetGroupName	=	var.SubnetGroupName
	DBMultiAZ	=	var.DBMultiAZ
	DBAllocatedStorage	=	var.DBAllocatedStorage
	DBMaxAllocatedStorage	=	var.DBMaxAllocatedStorage
	DBCloudwatchLogExports	=	var.DBCloudwatchLogExports
	DBAutoMinorVersionUpgrade	=	var.DBAutoMinorVersionUpgrade
	DBAutoMajorVersionUpgrade	=	var.DBAutoMajorVersionUpgrade
	DBBackupRetentionPeriod	=	var.DBBackupRetentionPeriod
	DBEngineMode	=	var.DBEngineMode
	DBEngineVersion	=	var.DBEngineVersion
	DBMasterUserPassword	=	var.DBMasterUserPassword
	DBMasterUsername	=	var.DBMasterUsername
	DBPort = var.DBPort
	CustomDBSecurityGroup	=	module.RDS-SG.RDS-SG-Output.id
	CopyTagsToSnapshot	=	var.CopyTagsToSnapshot
	PubliclyAccessible	=	var.PubliclyAccessible
	EnablePerformanceInsights	=	var.EnablePerformanceInsights
	PerformanceInsightsRetentionPeriod	=	var.PerformanceInsightsRetentionPeriod
	DBDeletionProtection	=	var.DBDeletionProtection
	DBDeleteAutomatedBackups	=	var.DBDeleteAutomatedBackups
	DBStorageType	=	var.DBStorageType
	DBStorageEncrypted	=	var.DBStorageEncrypted
	Iops	=	var.Iops
	SkipFinalSnapshot	=	var.SkipFinalSnapshot
}