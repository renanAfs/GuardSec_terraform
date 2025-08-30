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
  description = "Classe de instancia para o RDS."
  type        = string
  # ATENCAO: PostgreSQL 16+ nao e compativel com t2.micro.
  # Usando t4g.micro, que tambem faz parte do Free Tier moderno da AWS.
  default     = "db.t4g.micro"
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
  default = "guardsecfiap2025"
}

variable "domain_name" {
  description = "Seu nome de dominio registrado (ex: seudominio.com.br). Deixe em branco se nao quiser criar a zona DNS."
  type        = string
  default     = "guardsec.com.br"
}

variable "subdomain" {
  description = "O subdominio para a aplicacao (ex: 'app', 'www', etc.)."
  type        = string
  default     = "app"
}

# variable "fortigate_ami" {
#   description = "ID da AMI para a VM do FortiGate (obtenha do AWS Marketplace)."
#   type        = string
# }

# variable "fortimanager_ami" {
#   description = "ID da AMI para a VM do FortiManager (obtenha do AWS Marketplace)."
#   type        = string
# }
