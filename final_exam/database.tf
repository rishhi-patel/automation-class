
resource "aws_db_subnet_group" "oracle_subnet_group" {
  name = "oracle-subnet-group"
  subnet_ids = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name = "OracleSubnetGroup"
  }
}

resource "aws_db_instance" "mysql_shrine" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "oracle_db"
  username             = "elder"
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.oracle_subnet_group.name
  publicly_accessible  = true

  tags = {
    Name = "MySQLShrine"
  }
}
