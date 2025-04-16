output "web_server_1_public_ip" {
  value = aws_instance.web1.public_ip
}

output "web_server_2_public_ip" {
  value = aws_instance.web2.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}
