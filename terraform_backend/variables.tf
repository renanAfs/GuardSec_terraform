# terraform_backend/variables.tf

variable "bucket_name" {
  description = "Nome do bucket S3 para o estado do Terraform. DEVE SER GLOBALMENTE ÚNICO."
  type        = string
  # Altere para um nome único, por exemplo: guardsec-tfstate-seu-nome-12345
  default     = "guardsec-tfstate-renanafs-2025" 
}

variable "table_name" {
  description = "Nome da tabela do DynamoDB para o bloqueio de estado."
  type        = string
  default     = "guardsec-tflock"
}
