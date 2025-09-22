# terraform/backend.tf

terraform {
  backend "s3" {
    # Altere para o nome do bucket que você definiu em terraform_backend/variables.tf
    bucket         = "guardsec-tfstate-renanafs-2025"
    key            = "global/guardsec/terraform.tfstate"
    region         = "us-east-1"

    # Altere para o nome da tabela que você definiu em terraform_backend/variables.tf
    dynamodb_table = "guardsec-tflock"
  }
}
