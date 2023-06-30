data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_availability_zone" "name" {
  for_each = toset(local.vpc_azs)

  zone_id = each.value
}
