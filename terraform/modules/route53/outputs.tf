# terraform/modules/route53/outputs.tf

output "zone_id" {
  description = "O ID da zona hospedada criada"
  value       = aws_route53_zone.primary.id
}

output "name_servers" {
  description = "Lista de servidores de nome para a zona hospedada"
  value       = aws_route53_zone.primary.name_servers
  sensitive   = true
}
