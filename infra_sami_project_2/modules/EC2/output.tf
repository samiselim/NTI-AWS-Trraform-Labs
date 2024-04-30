output "public_ec2_ips" {
  value = aws_instance.ec2_public[*].public_ip
}
output "public_ec2_ids" {
  value = aws_instance.ec2_public[*].id
}
output "private_ec2_ips" {
  value = aws_instance.ec2_private[*].public_ip
}
output "private_ec2_ids" {
  value = aws_instance.ec2_private[*].id
}