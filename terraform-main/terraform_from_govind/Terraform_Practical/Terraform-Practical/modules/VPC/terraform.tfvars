Region = "ap-south-1"
ProjectName = "Hotelzify"
Environment = "Dev"
WantDataBaseTier = "yes"
NumberOfAZs = "3"
AvailabilityZones = [ "ap-south-1a","ap-south-1b","ap-south-1c" ]
VpcCidr = "172.16.0.0/16"
VpcTenancy = "default"
WantNatGatewayForPrivateSubnets = "yes"
NumberOfNATs = "single"
WantNatGatewayForDataBaseSubnets = "yes"
WantVpcFlowLogs = "enable"
DataSubnetCidr ={ 
  3 = ["172.16.64.0/22", "172.16.68.0/22", "172.16.72.0/22"]
}
PublicSubnetCidr = {
  3 = [ "172.16.0.0/22", "172.16.4.0/22", "172.16.8.0/22" ]
}
PrivateSubnetCidr = {
  3 = [ "172.16.16.0/20", "172.16.32.0/20", "172.16.48.0/20" ]
}