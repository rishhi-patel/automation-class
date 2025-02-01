provider "aws" {
  region     = "us-east-1"
  access_key = "ASIA3PEVR5PP7BXP3UDS"
  secret_key = "c0zchky/s+aK2F7miVAHdc7TAIYmkk7zn9aal7NH"
  token      = "IQoJb3JpZ2luX2VjENL//////////wEaCXVzLXdlc3QtMiJIMEYCIQDWqEJL/KwPJg3akOf5oW11oxGL1vMcKESNn3nmhs9kOgIhAJ6FOqojC4dBoW+7KrW3BEzNd4a1Tmtr8UWBW5MFCDKCKr0CCNv//////////wEQARoMNzg4NDQwMTQ4OTU5IgxExqpP6gWD8Mok4YoqkQLTzLF08KOqm/1szvHanNZHVXYQpIL2fyNG3QTowK6dorEaFuLRnRuncSKkJa6nwt9ZwQHH4TojxytvilXZ0Kpe3wKAzopGsDnWcXPr3Kdq61InCchJ0LvS8Mls/NWChaOOJdwctiSWeSfpfAZwdmbPRyNN1ZN1m7Gd827R8gFko/B+ulqdUo8MYC6A4cUldRP+DTWFVr6m47UbwExW4Y7I2hXehjozNOpKM+PUjsLuLko6lMRqeFd90mQ2yJMElc4o72vHg3r0pFKRuIKsqB8qNCJgUr1u/l2LDxN+G6PJAm475HzCLxBNE6a56jkihVb+cAhLTsKqcuXlVYGHFCe9rhzfJwuLC/Ixcahmb0D4LlMw3br5vAY6nAG8llhVX9DmRnsfDtL4ZUFcQ5iYL5haFUXXTHU6x9Wmlf9pp+/5edY+BhDWetRgPXZIMCjc/dSMH+o4C6I7/GAU91ZtpPzC2qiaYgbBH4kVh9SibmqIj15YO2jaP9TM1+EOYV8BN5JQgD07MbaiICdjWipeGKCLhhu4HYXQjBMZKOPf4WifBUDUbxSWwihGtabBkmIW1wR/dAeU020="

}

# DATA
data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# RESOURCES

# NETWORKING
resource "aws_vpc" "app" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

}

# INSTANCES
resource "aws_instance" "nginx1" {
  ami           = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type = "t3.micro"

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Taco Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF

}

