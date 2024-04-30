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
ec2_config = {
    "instance_count" = [2,2]
    "instance_type" = ["t2.micro" , "t2.micro","t2.micro" , "t2.micro"]
    "key_name" = ["key"]
    "instance_name" = ["public_ec2" , "public_ec2","private_ec2" , "private_ec2"]
}
sg_config = {
  ingress_count = [{count = 3}]
  ingress_rule = [{
    port = 443
    protocol = "tcp"
    cidr = "0.0.0.0/0"
  } , 
  { port = 80
    protocol = "tcp"
    cidr = "0.0.0.0/0"
  },
  { port = 22
    protocol = "tcp"
    cidr = "0.0.0.0/0"
  }]
}

lb_config = {
    lb_count = [2]
    lb_name = ["public" , "private"]
    internal = [false , true]
    instances_count = [4]
    
  }