output "cluster_endpoint" {
  value       = aws_rds_cluster.main.endpoint
  description = "Endpoint of the Aurora cluster"
}

output "master_credentials_secret_arn" {
  value       = aws_secretsmanager_secret.master_credentials.arn
  description = "ARN of the AWS Secrets Manager secret for master credentials"
}
