provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "nti-vpc" {
    cidr_block       = "10.0.0.0/16"
    enable_dns_hostnames = true

    tags = {
    Name = "nti-vpc"
    }
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.nti-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-3a"
  map_public_ip_on_launch = true
  tags = {
    Name: "${var.sub_prefix}-subnet1"
  }
}


resource "aws_subnet" "subnet3" {
  vpc_id = aws_vpc.nti-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-3b"
  map_public_ip_on_launch = true
  tags = {
    Name: "${var.sub_prefix}-subnet3"
  }
}


resource "aws_internet_gateway" "gate_way1" {
    vpc_id = aws_vpc.nti-vpc.id
    tags = {
      Name: "${var.sub_prefix}-igw"
    }
}

resource "aws_route_table_association" "rtb_association1" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.route_table1.id
}

resource "aws_route_table_association" "rtb_association3" {
    subnet_id = aws_subnet.subnet3.id
    route_table_id = aws_route_table.route_table3.id
}



resource "aws_route_table" "route_table1" {
    vpc_id = aws_vpc.nti-vpc.id

    route {
        cidr_block ="0.0.0.0/0"
        gateway_id = aws_internet_gateway.gate_way1.id
    }
    tags = {
      Name: "${var.sub_prefix}-rtb1"
    }
}



resource "aws_route_table" "route_table3" {
    vpc_id = aws_vpc.nti-vpc.id

    route {
        cidr_block ="0.0.0.0/0"
        gateway_id = aws_internet_gateway.gate_way1.id
    }
    tags = {
      Name: "${var.sub_prefix}-rtb3"
    }
}

resource "aws_security_group" "security_group1" {
    name = "${var.sub_prefix}-sg1"
    vpc_id = aws_vpc.nti-vpc.id
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
    egress {
        from_port = 0
        to_port = 0 
        protocol = "-1"  #any protocol
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
      Name: "${var.sub_prefix}-sg"
    }
}


resource "aws_security_group" "security_group3" {
    name = "${var.sub_prefix}-sg3"
    vpc_id = aws_vpc.nti-vpc.id
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
    egress {
        from_port = 0
        to_port = 0 
        protocol = "-1"  #any protocol
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
      Name: "${var.sub_prefix}-sg3"
    }
}

resource "aws_security_group" "lb-sg" {
    name = "${var.sub_prefix}-lb-sg"
    vpc_id = aws_vpc.nti-vpc.id
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
        protocol = "-1"  #any protocol
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
      Name: "${var.sub_prefix}-sg4"
    }
}

resource "aws_lb" "nti-lb1" {
  name               = "${var.sub_prefix}-lb1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [aws_subnet.subnet1.id , aws_subnet.subnet3.id]

  enable_deletion_protection = false
  access_logs {
    bucket  = aws_s3_bucket.nti-bucket.id
    enabled = true
  }

  tags = {
    Name = "${var.sub_prefix}-lb1"
  }
}
resource "aws_lb_listener" "nti-listner1" {
  load_balancer_arn = aws_lb.nti-lb1.arn
  port              = "80"
  protocol          = "HTTP"

default_action {
    type             = "forward"
     forward {
      target_group {
        arn = aws_lb_target_group.public_target_group1.arn
      }

      target_group {
        arn = aws_lb_target_group.public_target_group3.arn
      }

      stickiness {
        enabled  = true
        duration = 28800
      }
    }
  }
}

resource "aws_lb_target_group" "public_target_group1" {
  name     = "public-target-group1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.nti-vpc.id
}
resource "aws_lb_target_group" "public_target_group3" {
  name     = "public-target-group3"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.nti-vpc.id
}

resource "aws_instance" "instance1" {
  ami             = "ami-00c71bd4d220aa22a"  
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet1.id
  security_groups = [aws_security_group.security_group1.id]
  key_name = "ntikey"
  user_data = file("install_nginx.sh")
  tags = {
    Name = "instance1"
  }
}

resource "aws_lb_target_group_attachment" "attach_instance1" {
  target_group_arn = aws_lb_target_group.public_target_group1.arn
  target_id        = aws_instance.instance1.id
  port             = 80
}



resource "aws_instance" "instance3" {
  ami             = "ami-00c71bd4d220aa22a"  
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet3.id
  security_groups = [aws_security_group.security_group3.id]
  user_data = file("install_nginx.sh")
  key_name = "ntikey"
  tags = {
    Name = "instance3"
  }
}

resource "aws_lb_target_group_attachment" "attach_instance3" {
  target_group_arn = aws_lb_target_group.public_target_group3.arn
  target_id        = aws_instance.instance3.id
  port             = 80
}

resource "aws_s3_bucket" "nti-bucket" {
  bucket = "nti-bucket-lb-logs"
  force_destroy = true 
  tags = {
    Name        = "nti-lb-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.nti-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.nti-bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::009996457667:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.nti-bucket.id}/*"
    }
  ]
}
POLICY
}