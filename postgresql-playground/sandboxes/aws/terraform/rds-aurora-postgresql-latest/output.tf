output "environment" {
  value = module.rds-aurora-postgresql-latest
}

# output "aurora_cluster_endpoint" {
#   value       = module.aws-aurora-postgresql.aurora_cluster_endpoint
#   description = "Endpoint of the Aurora PostgreSQL cluster"
# }

# output "jump_box_public_ip" {
#   value       = module.aws-aurora-postgresql.jump_box_public_ip
#   description = "Public IP address of the Jump Box server"
# }

# output "jump_box_private_ip" {
#   value       = module.aws-aurora-postgresql.jump_box_private_ip
#   description = "Private IP address of the Jump Box server"
# }
