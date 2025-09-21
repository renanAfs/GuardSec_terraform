# terraform/modules/codedeploy/outputs.tf

output "deployment_group_name" {
  description = "O nome do grupo de deploy do CodeDeploy"
  value       = aws_codedeploy_deployment_group.blue_green.deployment_group_name
}
