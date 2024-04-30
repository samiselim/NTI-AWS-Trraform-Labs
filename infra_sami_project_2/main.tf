terraform {
  backend "s3" {
    bucket = "sami-statefile-bucket"
    key = "project2-statefile"
    region = "eu-west-3"
  }
}
resource "local_file" "public_ips" {
    content  = " \n DNS_lb : ${module.ALB.ALB_DNS[0]} \n publicIP 1: ${data.aws_instances.instances_data.public_ips[0]} \n publicIP 2: ${data.aws_instances.instances_data.public_ips[1]} \n privateIP 1: ${data.aws_instances.instances_data.private_ips[0]} \n privateIP 2: ${data.aws_instances.instances_data.private_ips[1]}"
    filename = "./ips.txt"
    depends_on = [ data.aws_instances.instances_data]
}

module "vpc" {
  source                 = "./modules/VPC"
  vpc_cidr               = var.vpc_cidr
  public_subnets_config  = var.public_subnets_config
  private_subnets_config = var.private_subnets_config
  vpc_name               = var.vpc_name
}
module "sg" {
  source = "./modules/SG"
  sg_config = var.sg_config
  sg_name = "sg"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "./modules/EC2"
  ec2_config = var.ec2_config
  vpc_id = module.vpc.vpc_id
  sg = module.sg.sg_id
  ec2_subnet_id = [
                  module.vpc.public_subnet_ids[0] ,
                  module.vpc.public_subnet_ids[1] ,
                  module.vpc.private_subnet_ids[0] ,
                  module.vpc.private_subnet_ids[1]
                  ]
  privte_lb_dns = module.ALB.ALB_DNS[1]
}
module "ALB" {
  source = "./modules/ALB"
  lb_config = var.lb_config
  sg = module.sg.sg_id
  vpc_id = module.vpc.vpc_id
  lb_subnets = [ module.vpc.public_subnet_ids , module.vpc.private_subnet_ids]
  target_group_instances_id_pub = module.ec2.public_ec2_ids
  target_group_instances_id_pri = module.ec2.private_ec2_ids
}

