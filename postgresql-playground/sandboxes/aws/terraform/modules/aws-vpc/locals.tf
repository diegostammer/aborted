locals {
  private_subnets = sort([for subnet in var.vpc_configuration.subnets : subnet.name if subnet.public == false])
  public_subnets  = sort([for subnet in var.vpc_configuration.subnets : subnet.name if subnet.public == true])
  vpc_azs         = sort(slice(data.aws_availability_zones.available.zone_ids, 0, length(local.private_subnets)))
  vpc_names = [
    for az_id in local.vpc_azs : data.aws_availability_zone.name[az_id].name
  ]
  subnet_pairs = zipmap(local.private_subnets, local.public_subnets)
  vpc_azs_pairs = merge(
    zipmap(local.private_subnets, local.vpc_azs),
    zipmap(local.public_subnets, local.vpc_azs)
  )
}
