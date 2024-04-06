resource "aws_vpc" "nti-vpc" {
    cidr_block       = "10.0.0.0/16"
    enable_dns_hostnames = true

    tags = {
    Name = "nti-vpc"
    }
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.nti-vpc.id
  cidr_block = var.subnet1-cidr
  availability_zone = var.zone
  map_public_ip_on_launch = true
  tags = {
    Name: "${var.sub_prefix}-subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.nti-vpc.id
  cidr_block = var.subnet2-cidr
  availability_zone = var.zone
  tags = {
    Name: "${var.sub_prefix}-subnet2"
  }
}

resource "aws_internet_gateway" "gate_way1" {
    vpc_id = aws_vpc.nti-vpc.id
    tags = {
      Name: "${var.sub_prefix}-igw"
    }
}
resource "aws_eip" "lb" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat_gate_way" {
    subnet_id = aws_subnet.subnet1.id
    allocation_id = aws_eip.lb.id
}
resource "aws_route_table_association" "rtb_association1" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.route_table1.id
}
resource "aws_route_table_association" "rtb_association2" {
    subnet_id = aws_subnet.subnet2.id
    route_table_id = aws_route_table.route_table2.id
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

resource "aws_route_table" "route_table2" {
    vpc_id = aws_vpc.nti-vpc.id

    route {
        cidr_block ="0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gate_way.id
    }
    tags = {
      Name: "${var.sub_prefix}-rtb2"
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


resource "aws_security_group" "security_group2" {
    name = "${var.sub_prefix}-sg2"
    vpc_id = aws_vpc.nti-vpc.id
    ingress {
        from_port = 22
        to_port = 22
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