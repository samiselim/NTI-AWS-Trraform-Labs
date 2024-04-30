variable "vpc_cidr" {
  type        = string
  description = "Cidr Block for VPC ex: 10.0.0.0/16"
}
variable "vpc_name" {
  type        = string
  description = "Name of VPC"
}
variable "private_subnets_config" {
  type = map(any)
}
variable "public_subnets_config" {
  type = map(any)
}
data "aws_instances" "name" {
}
variable "sg_config" {
  type = map(any)
}
variable "ec2_config" {
  type = map(list(any))
}
variable "lb_config" {
  type = map(any)
}
