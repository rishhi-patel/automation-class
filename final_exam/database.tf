# Define the Oracle's Subnet Group
resource "aws_db_subnet_group" "oracle_subnet_group" {
  name       = "oracle-subnet-group"
  subnet_ids = ["<public_subnet_1_id>", "<public_subnet_2_id>"]

  tags = {
    Name = "OracleSubnetGroup"
  }
}

# Define the RDS MySQL Shrine
resource "aws_db_instance" "mysql_shrine" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  db_name              = "oracle_db"
  username             = "elder"
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.oracle_subnet_group.name
  publicly_accessible  = true

  tags = {
    Name = "MySQLShrine"
  }
}
