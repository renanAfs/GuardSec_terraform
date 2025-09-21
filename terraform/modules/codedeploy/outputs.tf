# terraform/modules/codedeploy/outputs.tf

output "app_name" {
  description = "Nome da aplicação CodeDeploy"
  value       = aws_codedeploy_app.main.name
}

output "deployment_group_name" {
  description = "Nome do grupo de deploy Blue/Green"
  value       = aws_codedeploy_deployment_group.blue_green.name
}
