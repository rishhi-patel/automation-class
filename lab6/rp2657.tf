provider "aws" {
  region = "us-east-1"
}

locals {
  s3_bucket_name = "rishi-patel-8972657-web-bucket"
}

variable "resource_tags" {
  default = {
    Owner     = "Rishi Patel"
    StudentID = "8972657"
    Project   = "AWS Terraform Lab 5"
  }
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

resource "aws_s3_bucket" "web_bucket" {
  bucket        = local.s3_bucket_name
  force_destroy = true

  tags = var.resource_tags
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.web_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.web_bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.web_bucket.id}/*"
    }
  ]
}
EOF
}

resource "aws_s3_object" "htmlfile" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "index.html"
  source = "./webcontent/index.html"

  tags = var.resource_tags
}

resource "aws_s3_object" "errorfile" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "error.html"
  source = "./webcontent/error.html"

  tags = var.resource_tags
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}
