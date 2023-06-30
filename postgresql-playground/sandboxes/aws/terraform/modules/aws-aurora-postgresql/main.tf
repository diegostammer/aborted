resource "random_password" "master_password" {
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret" "master_credentials" {
  name = "rds/${var.cluster_name}/master-credentials"
}

resource "aws_security_group" "this" {
  name        = "${var.cluster_name}-security-group"
  description = "Security group for Aurora cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_db_subnet_group" "this" {
  name       = "${var.cluster_name}-subnet-group"
  subnet_ids = var.subnets_ids

  tags = {
    Name = "${var.cluster_name}-subnet-group"
  }
}

resource "aws_rds_cluster" "main" {
  cluster_identifier     = var.cluster_name
  engine                 = "aurora-postgresql"
  engine_version         = var.engine_version
  master_username        = var.master_username
  master_password        = random_password.master_password.result
  vpc_security_group_ids = [aws_security_group.this.id]
  availability_zones     = var.allowed_availability_zones
  db_subnet_group_name   = aws_db_subnet_group.this.name
  skip_final_snapshot    = true

  storage_encrypted = true

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_rds_cluster_instance" "main" {
  count               = var.num_instances
  identifier          = "${var.cluster_name}-${count.index}"
  cluster_identifier  = aws_rds_cluster.main.id
  instance_class      = var.instance_type
  engine              = "aurora-postgresql"
  engine_version      = var.engine_version
  publicly_accessible = false

  tags = {
    Name = "${var.cluster_name}-${count.index}"
  }
}

resource "aws_secretsmanager_secret_version" "master_credentials_version" {
  depends_on = [
    aws_rds_cluster_instance.main,
    random_password.master_password
  ]

  secret_id = aws_secretsmanager_secret.master_credentials.id
  secret_string = jsonencode({
    "username" : var.master_username,
    "password" : random_password.master_password.result,
    "endpoint" : aws_rds_cluster.main.endpoint,
    "port" : var.cluster_port
  })
}

# resource "aws_db_security_group" "main" {
#   name        = "${var.cluster_name}-security-group"
#   description = "Security group for the Aurora cluster"

#   ingress {
#     from_port   = var.cluster_port
#     to_port     = var.cluster_port
#     protocol    = "tcp"
#     cidr_blocks = ["
