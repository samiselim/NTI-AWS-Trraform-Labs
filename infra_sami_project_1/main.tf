data "aws_ami" "aws_image_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.4.20240416.0-kernel-6.1-x86_64"]
  }
}

module "vpc" {
  source                 = "./VPC"
  vpc_cidr               = var.vpc_cidr
  public_subnets_config  = var.public_subnets_config
  private_subnets_config = var.private_subnets_config
  vpc_name               = var.vpc_name
}
resource "aws_security_group" "sg" {
    name = "sg"
    vpc_id = module.vpc.vpc_id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0 
        protocol = "-1" 
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
      Name: "sg"
    }
}
resource "aws_launch_template" "launch_template" {
  name_prefix   = "launch_template"
  image_id      = data.aws_ami.aws_image_latest.id
  instance_type = "t2.micro"
  user_data = filebase64("install_appache.sh")
   block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = 20
    }
  }
  network_interfaces {
    security_groups = [aws_security_group.sg.id]
  }
}

resource "aws_autoscaling_group" "autoScallingGroup" {
  target_group_arns = [aws_lb_target_group.target_group.arn]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 1
  vpc_zone_identifier       = module.vpc.private_subnet_ids

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}

resource "aws_lb" "load_balancer" {
  name               = "lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets = module.vpc.public_subnet_ids
  enable_deletion_protection = false

  tags = {
    Name = "lb"
  }
}
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

default_action {
    type             = "forward"
     forward {
      target_group {
        arn = aws_lb_target_group.target_group.arn
      }
      stickiness {
        enabled  = true
        duration = 28800
      }
    }
  }
}
resource "aws_lb_target_group" "target_group" {
  name     = "public-target-group1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  
    health_check {
    protocol             = "HTTP"
    path                 = "/var/www/html/index.html"
    interval             = 30
    timeout              = 10
    healthy_threshold    = 2
    unhealthy_threshold  = 2
    matcher              = "200-399"
  }
}


data "aws_instances" "instances_data" {
  filter {
    name = "tag:aws:ec2launchtemplate:version"
    values = ["1"]
  }
  depends_on = [ 
                 aws_launch_template.launch_template,
                 aws_autoscaling_group.autoScallingGroup
               ]

}
resource "local_file" "public_ips" {
    content  = join("  ,  ", data.aws_instances.instances_data.private_ips)
    filename = "./ips.txt"
    depends_on = [ data.aws_instances.instances_data ]
}