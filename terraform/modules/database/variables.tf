# terraform/modules/database/variables.tf

variable "project_name" {
  description = "O nome do projeto"
  type        = string
  default     = "guardsec"
}

variable "db_instance_class" {
  description = "A classe da instância do RDS"
  type        = string
}

variable "db_username" {
  description = "O nome de usuário para o banco de dados"
  type        = string
}

variable "db_password" {
  description = "A senha para o banco de dados"
  type        = string
  sensitive   = true
}

variable "db_subnet_group_name" {
  description = "O nome do grupo de sub-redes do banco de dados"
  type        = string
}

variable "db_sg_id" {
  description = "O ID do grupo de segurança para o banco de dados"
  type        = string
}
