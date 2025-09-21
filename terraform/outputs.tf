# outputs.tf

output "alb_dns_name" {
  description = "DNS público do Application Load Balancer."
  value       = module.network.alb_dns_name
}

output "rds_endpoint" {
  description = "Endpoint do banco de dados RDS."
  value       = module.database.db_instance_endpoint
}