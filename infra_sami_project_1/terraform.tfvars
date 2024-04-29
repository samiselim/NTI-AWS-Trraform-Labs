vpc_name     = "vpc1"
vpc_cidr     = "10.0.0.0/16"

public_subnets_config = {
  subnet_count = [2]
  subnet_cidrs = ["10.0.0.0/24" , "10.0.1.0/24"]
  subnet_azs   = ["eu-west-3a" , "eu-west-3b"]
}
private_subnets_config = {
  subnet_count = [2]
  subnet_cidrs = ["10.0.2.0/24" , "10.0.3.0/24"]
  subnet_azs   = ["eu-west-3a" , "eu-west-3b"]
}
# ec2_config = {
#     "instance_count" = [2]
#     "instance_type" = ["t2.micro" , "t2.micro"]
#     # security_groups = []
#     "key_name" = ["sami_key"]
#     "instance_name" = ["public_ec2" , "private_ec2"]
# }