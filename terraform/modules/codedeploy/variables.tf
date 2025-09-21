# terraform/modules/codedeploy/variables.tf

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "asg_name" {
  description = "Nome do Auto Scaling Group para o qual o CodeDeploy fará o deploy"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN do Listener do ALB para o Blue/Green"
  type        = string
}

variable "blue_target_group_name" {
  description = "Nome do Target Group 'Blue'"
  type        = string
}

variable "green_target_group_name" {
  description = "Nome do Target Group 'Green'"
  type        = string
}

variable "service_role_arn" {
  description = "ARN of the IAM service role for CodeDeploy"
  type        = string
}
