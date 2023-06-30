output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets_ids" {
  value = [
    for subnet in local.public_subnets : aws_subnet.this[subnet].id
  ]
}

output "private_subnets_ids" {
  value = [
    for subnet in local.private_subnets : aws_subnet.this[subnet].id
  ]
}

output "availability_zones" {
  value = local.vpc_names
}
