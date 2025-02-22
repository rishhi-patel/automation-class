# Define the AWS provider
provider "aws" {
  region = "us-east-1" # Change this if needed
}

# Local variables for bucket name
locals {
  s3_bucket_name = "rishi-patel-8972657-web-bucket" # Ensure uniqueness
}

# Define resource tags
variable "resource_tags" {
  default = {
    Owner     = "Rishi Patel"
    StudentID = "8972657"
    Project   = "AWS Terraform S3 Lab"
  }
}

# Create an S3 bucket
resource "aws_s3_bucket" "web_bucket" {
  bucket        = local.s3_bucket_name
  force_destroy = true # Allows Terraform to delete the bucket even if it contains objects

  tags = var.resource_tags
}

# Enable Static Website Hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.web_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Define a bucket policy to allow public access
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

# Upload web content to S3
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

# Block public access settings to allow access via the bucket policy
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.web_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Output the website endpoint
output "website_url" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}
