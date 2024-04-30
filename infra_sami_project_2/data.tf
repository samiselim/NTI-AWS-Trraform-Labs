
data "aws_instances" "instances_data" {
  filter {
    name = "tag:ENV"
    values = ["Public_project2"]
  }
}

data "aws_ami" "aws_image_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240423"]
  }
}