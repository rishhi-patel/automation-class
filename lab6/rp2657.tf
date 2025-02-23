
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
    Project   = "AWS Terraform S3 Lab"
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
  key    = "webcontent/index.html"
  source = "./webcontent/index.html"

  tags = var.resource_tags
}

resource "aws_s3_object" "errorfile" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "webcontent/error.html"
  source = "./webcontent/error.html"

  tags = var.resource_tags
}

resource "aws_s3_object" "stylesheet" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "webcontent/styles.css"
  source = "./webcontent/styles.css"

  tags = var.resource_tags
}

resource "aws_s3_object" "programsimg" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "webcontent/programs.jpg"
  source = "./webcontent/programs.jpg"

  tags = var.resource_tags
}

resource "aws_s3_object" "studentsimg" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "webcontent/students.jpg"
  source = "./webcontent/students.jpg"

  tags = var.resource_tags
}


resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.web_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}
