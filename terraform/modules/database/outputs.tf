# terraform/modules/database/outputs.tf

output "db_instance_endpoint" {
  description = "O endpoint do banco de dados RDS"
  value       = aws_db_instance.default.endpoint
}

output "db_instance_id" {
  description = "O ID da instância do banco de dados RDS"
  value       = aws_db_instance.default.id
}
