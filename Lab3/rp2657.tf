provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA3PEVR5PP5CRRDGYJ"
  secret_key = "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"
}


data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}




resource "aws_instance" "nginx1" {
  ami           = data.aws_ssm_parameter.amzn2_linux.value
  instance_type = "t3.micro"

  tags = {
    Name = "8972657_RishikumarPatel_Lab3"
  }

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Taco Team Server</title></head><body style="background-color:#1F778D"><p style="text-align: center;"><span style="color:#FFFFFF;"><span style="font-size:28px;">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF
}
