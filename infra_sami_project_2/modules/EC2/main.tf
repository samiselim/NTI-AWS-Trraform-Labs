data "aws_ami" "aws_image_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240423"]
  }
}

resource "aws_instance" "ec2_public" {
  count = var.ec2_config["instance_count"][0]
  ami             = data.aws_ami.aws_image_latest.id
  instance_type   = var.ec2_config["instance_type"][count.index]
  subnet_id       = var.ec2_subnet_id[count.index]
  associate_public_ip_address = true
  security_groups = [var.sg]
  key_name = var.ec2_config["key_name"][0]
  tags = {
    Name = var.ec2_config["instance_name"][count.index]
    ENV = "Public_project2"
  }
   user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo cat > /etc/nginx/sites-enabled/default << EOL
server {
    listen 80 default_server;
    location / {
      proxy_pass http://${var.privte_lb_dns};
    }
}
  
EOL
sudo systemctl restart nginx
EOF
}
resource "aws_instance" "ec2_private" {
  count = var.ec2_config["instance_count"][1]
  ami             = data.aws_ami.aws_image_latest.id
  instance_type   = var.ec2_config["instance_type"][count.index+2]
  subnet_id       = var.ec2_subnet_id[count.index+2]
  security_groups = [var.sg]
  key_name = var.ec2_config["key_name"][0]
  user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
systemctl restart apache2
EOF
  tags = {
    Name = var.ec2_config["instance_name"][count.index+2]
    ENV = "Private_project2"
  }
  
}
