output "rds_endpoint" { 
  description = "Endpoint de conexão do banco de dados RDS."
  value = aws_db_instance.main.endpoint 
}

output "asg_name" {
  description = "Nome do Auto Scaling Group das instâncias web"
  value       = aws_autoscaling_group.web_server.name
}

output "db_instance_id" {
  description = "ID da instância RDS"
  value       = aws_db_instance.main.id
}