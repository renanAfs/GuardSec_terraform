output "asg_name" {
  description = "Nome do Auto Scaling Group das instâncias web"
  value       = aws_autoscaling_group.web_server.name
}
