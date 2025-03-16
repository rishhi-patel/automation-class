provider "aws" {
  region = var.aws_region
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15.2"
  instance_class       = var.instance_class
  db_name              = var.db_name
  username             = var.db_user
  password             = var.db_password
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
