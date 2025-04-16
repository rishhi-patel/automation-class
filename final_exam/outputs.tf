output "db_connection_string" {
  value = format(
    "admin:%s@%s:%d/%s",
    var.db_password,
    aws_db_instance.mysql_shrine.endpoint,
    aws_db_instance.mysql_shrine.port,
    aws_db_instance.mysql_shrine.name
  )
}
