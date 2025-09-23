# terraform/modules/monitoring/outputs.tf

output "notification_topic_arn" {
  description = "ARN do tópico SNS criado para notificações"
  value       = local.effective_notification_arn
}
