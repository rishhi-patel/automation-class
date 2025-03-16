provider "aws" {
  region = "us-east-1" # Change if needed
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15.2"
  instance_class       = "db.t3.micro"
  db_name              = "mydatabase"
  username             = "admin"
  password             = "SecureRishi123"
  parameter_group_name = "default.postgres15"
  publicly_accessible  = true
  skip_final_snapshot  = true

  tags = {
    Name       = "Lab-RDS-PostgreSQL"
    Student    = "Rishikumar Patel"
    Student_ID = "8972657"
  }
}

output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}
