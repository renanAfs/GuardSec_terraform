variable "project_name" { type = string }
variable "aws_region" { type = string }
variable "domain_name" { type = string }
variable "subdomain" { type = string }

variable "enable_shield_advanced" {
  description = "Habilita a proteção do AWS Shield Advanced para os recursos."
  type        = bool
  default     = false
}