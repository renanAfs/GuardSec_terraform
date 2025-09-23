# terraform/modules/monitoring/cloudwatch.tf

locals {
  # Decide qual ARN usar: o que foi passado como variável ou o do novo tópico criado.
  effective_notification_arn = var.notification_topic_arn != "" ? var.notification_topic_arn : (length(aws_sns_topic.notifications) > 0 ? aws_sns_topic.notifications[0].arn : "")
}

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

  alarm_actions = [local.effective_notification_arn]
  ok_actions      = [local.effective_notification_arn]
}

# -------------------------------------------------------------
# Alarme de Conexões para o Banco de Dados RDS
# -------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "db_high_connections" {
  count               = length(var.db_instance_id)
  alarm_name          = "${var.project_name}-db-high-connections-${var.db_instance_id[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "50" # Ajuste o threshold conforme a sua carga de trabalho
  alarm_description   = "Alarme quando as conexões do RDS excederem 50"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id[count.index]
  }

  alarm_actions = [local.effective_notification_arn]
  ok_actions      = [local.effective_notification_arn]
}

# -------------------------------------------------------------
# Tópico SNS para Notificações (Opcional)
# -------------------------------------------------------------
resource "aws_sns_topic" "notifications" {
  count = var.notification_topic_arn == "" ? 1 : 0
  name  = "${var.project_name}-notifications"
}

# -------------------------------------------------------------
# CloudTrail
# -------------------------------------------------------------

# Bucket S3 para armazenar os logs do CloudTrail
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.project_name}-cloudtrail-logs-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Política do Bucket S3 para permitir que o CloudTrail escreva nele
resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck",
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = "s3:GetBucketAcl",
        Resource  = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid       = "AWSCloudTrailWrite",
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      }
    ]
  })
}

# Trilha do CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_logging                = true

  # Integração com o CloudWatch Logs
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_to_cloudwatch.arn

  depends_on = [aws_s3_bucket_policy.cloudtrail_policy]
}

# Grupo de Logs do CloudWatch para o CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name = "/aws/cloudtrail/${var.project_name}"
  retention_in_days = 90
}

# Role para permitir que o CloudTrail envie logs para o CloudWatch
resource "aws_iam_role" "cloudtrail_to_cloudwatch" {
  name = "${var.project_name}-cloudtrail-cw-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_to_cloudwatch" {
  name = "${var.project_name}-cloudtrail-cw-policy"
  role = aws_iam_role.cloudtrail_to_cloudwatch.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
