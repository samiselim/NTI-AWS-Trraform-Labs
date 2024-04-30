
variable "ec2_config" {
  type = map(list(any))
}
variable "vpc_id" {
}
variable "sg" {
}
variable "ec2_subnet_id" {
  type = list(any)
}
variable "privte_lb_dns" {
}