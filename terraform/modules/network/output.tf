output "main_vpc_id" { value = aws_vpc.main.id }
output "security_vpc_id" { value = aws_vpc.security.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "security_public_subnet_id" { value = aws_subnet.security_public.id }
output "alb_dns_name" { value = aws_lb.main.dns_name }
output "alb_target_group_blue_name" { value = aws_lb_target_group.blue.name }
output "alb_target_group_green_name" { value = aws_lb_target_group.green.name }
output "alb_listener_arn" { value = aws_lb_listener.http.arn }
output "web_server_sg_id" { value = aws_security_group.web_server.id }
output "db_sg_id" { value = aws_security_group.db.id }
output "fortinet_sg_id" { value = aws_security_group.fortinet.id }
output "route53_zone_name_servers" {
  description = "Servidores de Nomes (NS) da Zona Hospedada. Configure-os no seu registrador de dominio."
  # A funcao 'try' evita erros caso a zona nao seja criada (se domain_name for vazio)
  value       = try(aws_route53_zone.main[0].name_servers, [])
}