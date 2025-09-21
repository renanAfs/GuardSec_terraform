# terraform/modules/monitoring/outputs.tf

output "notification_topic_arn" {
  description = "ARN do tópico SNS criado para notificações"
  value       = aws_sns_topic.notifications[0].arn
}
