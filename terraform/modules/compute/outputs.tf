output "rds_endpoint" { 
  description = "Endpoint de conexão do banco de dados RDS."
  value = aws_db_instance.rds-main.endpoint
}