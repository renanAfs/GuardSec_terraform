# terraform_backend/main.tf

provider "aws" {
  region = "us-east-1" # Ou a sua região de preferência
}

# Bucket S3 para armazenar o arquivo de estado do Terraform
resource "aws_s3_bucket" "tfstate" {
  bucket = var.bucket_name

  # Impede a exclusão acidental do bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Habilita o versionamento no bucket S3 para manter o histórico do estado
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Tabela do DynamoDB para o bloqueio de estado (state locking)
resource "aws_dynamodb_table" "tflock" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
