# terraform/modules/route53/variables.tf

variable "domain_name" {
  description = "O nome de domínio para a zona hospedada do Route 53"
  type        = string
}

variable "alb_dns_name" {
  description = "O nome DNS do Application Load Balancer"
  type        = string
}

variable "alb_zone_id" {
  description = "O ID da zona hospedada do Application Load Balancer"
  type        = string
}

variable "project_name" {
  description = "O nome do projeto"
  type        = string
}
