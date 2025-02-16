provider "aws" {
}

data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "MainVPC" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = { Name = "PublicSubnet" }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags                    = { Name = "PublicSubnet2" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = { Name = "MainIGW" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "PublicRouteTable" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "LoadBalancerSG" }
}

resource "aws_lb" "nginx" {
  name                       = "lb-8972657"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer_security_group.id]
  subnets                    = [aws_subnet.public_subnet.id, aws_subnet.public_subnet2.id]
  enable_deletion_protection = false
  tags                       = { Name = "NginxLoadBalancer" }
}

resource "aws_lb_target_group" "nginx_target_group" {
  name     = "nginxtargetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_target_group.arn
  }
}

resource "aws_instance" "nginx1" {
  ami                         = data.aws_ssm_parameter.amzn2_linux.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.load_balancer_security_group.id]
  associate_public_ip_address = true
  tags = {
  Name = "8972657_RishiPatel_Nginx-Server-1" }

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Rishi Server 1</title></head><body style="background-color:#1F778D"><p style="text-align: center;"><span style="color:#FFFFFF;"><span style="font-size:28px;">Welcome to Server 1, Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF
}

resource "aws_instance" "nginx2" {
  ami                         = data.aws_ssm_parameter.amzn2_linux.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet2.id
  vpc_security_group_ids      = [aws_security_group.load_balancer_security_group.id]
  associate_public_ip_address = true
  tags = {
    Name = "8972657_RishiPatel_Nginx-Server-2"
  }
  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Rishi Server 2</title></head><body style="background-color:#000000"><p style="text-align: center;"><span style="color:#FFFFFF;"><span style="font-size:28px;">Welcome to Server 2, Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF
}

resource "aws_lb_target_group_attachment" "nginx1" {
  target_group_arn = aws_lb_target_group.nginx_target_group.arn
  target_id        = aws_instance.nginx1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "nginx2" {
  target_group_arn = aws_lb_target_group.nginx_target_group.arn
  target_id        = aws_instance.nginx2.id
  port             = 80
}

