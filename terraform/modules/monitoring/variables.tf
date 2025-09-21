# terraform/modules/monitoring/variables.tf

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "asg_name" {
  description = "Nome do Auto Scaling Group das instâncias web"
  type        = string
}

variable "db_instance_id" {
  description = "ID da instância RDS"
  type        = string
}

variable "notification_topic_arn" {
  description = "ARN do tópico SNS para enviar notificações de alarme"
  type        = string
  default     = "" # Opcional
}
