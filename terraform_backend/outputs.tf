# terraform_backend/outputs.tf

output "s3_bucket_name" {
  description = "Nome do bucket S3 criado para o backend."
  value       = aws_s3_bucket.tfstate.bucket
}

output "dynamodb_table_name" {
  description = "Nome da tabela do DynamoDB criada para o bloqueio de estado."
  value       = aws_dynamodb_table.tflock.name
}
