# terraform/modules/route53/route53.tf

# Cria a zona hospedada pública no Route 53
resource "aws_route53_zone" "primary" {
  name = var.domain_name

  tags = {
    Name = "${var.project_name}-zone"
  }
}

# Cria o registro 'A' para apontar o subdomínio para o Application Load Balancer
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
