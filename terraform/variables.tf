# variables.tf

variable "aws_region" {
  description = "Região da AWS para implantar a infraestrutura."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto para usar como prefixo nos recursos."
  type        = string
  default     = "guardsec"
}

variable "instance_type" {
  description = "Tipo de instância EC2 para os web servers."
  type        = string
  default     = "t2.micro" # Free Tier
}

variable "instance_ami" {
  description = "AMI para as instancias EC2. Este valor sera ignorado pois estamos usando busca dinamica."
  type        = string
  default     = null # Removemos a AMI fixa daqui
}

variable "db_instance_class" {
  description = "Classe de instância para o RDS."
  type        = string
  default     = "db.t2.micro" # Free Tier
}

variable "db_username" {
  description = "Usuário master do banco de dados RDS."
  type        = string
  default     = "guarduser"
}

variable "db_password" {
  description = "Senha do usuário master do banco de dados RDS."
  type        = string
  sensitive   = true
  default = "fiap"
}

# variable "fortigate_ami" {
#   description = "ID da AMI para a VM do FortiGate (obtenha do AWS Marketplace)."
#   type        = string
# }

# variable "fortimanager_ami" {
#   description = "ID da AMI para a VM do FortiManager (obtenha do AWS Marketplace)."
#   type        = string
# }