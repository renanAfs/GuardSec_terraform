# terraform/modules/monitoring/cloudwatch.tf

# -------------------------------------------------------------
# Alarme de CPU para o Auto Scaling Group
# -------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "asg_high_cpu" {
  alarm_name          = "${var.project_name}-asg-high-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarme quando a CPU do ASG exceder 80%"
  
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [var.notification_topic_arn]
  ok_actions      = [var.notification_topic_arn]
}

# -------------------------------------------------------------
# Alarme de Conexões para o Banco de Dados RDS
# -------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "db_high_connections" {
  alarm_name          = "${var.project_name}-db-high-connections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "50" # Ajuste o threshold conforme a sua carga de trabalho
  alarm_description   = "Alarme quando as conexões do RDS excederem 50"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  alarm_actions = [var.notification_topic_arn]
  ok_actions      = [var.notification_topic_arn]
}

# -------------------------------------------------------------
# Tópico SNS para Notificações (Opcional)
# -------------------------------------------------------------
resource "aws_sns_topic" "notifications" {
  count = var.notification_topic_arn == "" ? 1 : 0
  name  = "${var.project_name}-notifications"
}
