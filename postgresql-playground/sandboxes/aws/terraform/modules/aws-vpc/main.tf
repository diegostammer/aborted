terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.1"
    }
  }
}

/*

An AWS VPC (Virtual Private Cloud) is a virtual network environment provided by Amazon Web Services (AWS).
It allows you to create and manage a logically isolated section of the AWS cloud where you can launch
resources such as EC2 instances, RDS databases, and more.

*/
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_configuration.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_configuration.name
  }
}

/*

An AWS Internet Gateway is a horizontally scalable, highly available AWS service that provides a connection
between your Virtual Private Cloud (VPC) and the internet.
It acts as an entry and exit point for internet traffic to and from your VPC.

*/
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_configuration.name}-internet-gateway"
  }
}

/*

An AWS subnet, short for "subnetwork," is a segmented portion of an Amazon Virtual Private Cloud (VPC).
It is a logical subdivision of an IP network within the VPC that allows you to
organize and isolate resources based on specific network requirements.

*/
resource "aws_subnet" "this" {
  for_each = { for subnet in var.vpc_configuration.subnets : subnet.name => subnet }

  vpc_id                  = aws_vpc.this.id
  availability_zone_id    = local.vpc_azs_pairs[each.key]
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = each.key
  }
}

/*

An Elastic IP (EIP) is a static, public IPv4 address provided by Amazon Web Services (AWS).
It is associated with your AWS account and can be dynamically assigned to resources such as Amazon EC2 instances,
NAT Gateways, load balancers, and more.

*/
resource "aws_eip" "nat_gateway" {

  depends_on = [aws_internet_gateway.this]

  for_each = toset(local.private_subnets)
  domain   = "vpc"

  tags = {
    Name = "${each.key}-eip"
  }
}

/*

AWS NAT Gateway, or Network Address Translation Gateway,
is a managed service provided by Amazon Web Services (AWS) that allows resources within a
private subnet to communicate with the internet while remaining private.
It provides outbound internet access for resources within private subnets in an Amazon Virtual Private Cloud (VPC).

*/
resource "aws_nat_gateway" "this" {
  for_each = toset(local.private_subnets)

  allocation_id = aws_eip.nat_gateway[each.value].id
  subnet_id     = aws_subnet.this[local.subnet_pairs[each.value]].id

  tags = {
    Name = "${local.subnet_pairs[each.value]}-nat-gateway"
  }
}

/*

An AWS route table is a virtual networking component that controls the traffic flow between subnets within an 
Amazon Virtual Private Cloud (VPC) or between a VPC and the internet.
It acts as a set of rules or instructions that determine how network traffic is directed within a VPC.

*/
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
}

/*

In the context of AWS networking, an AWS route refers to a specific entry in a route table that determines 
how network traffic is directed from a source to a destination.
It defines the path or next hop for the traffic based on the destination IP address.

*/
resource "aws_route" "public_internet_gateway" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
}

/*

In AWS networking, an AWS route table association refers to the link between a subnet and a route table.
It determines which route table is used for routing traffic within a subnet.

*/
resource "aws_route_table_association" "public" {
  for_each = toset(local.public_subnets)

  subnet_id      = aws_subnet.this[each.value].id
  route_table_id = aws_route_table.public.id
}

/* Private */

resource "aws_route_table" "private" {
  for_each = toset(local.private_subnets)

  vpc_id = aws_vpc.this.id
}

resource "aws_route" "private_nat_gateway" {
  for_each = toset(local.private_subnets)

  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private[each.value].id
  nat_gateway_id         = aws_nat_gateway.this[each.value].id
}

resource "aws_route_table_association" "private" {
  for_each = toset(local.private_subnets)

  subnet_id      = aws_subnet.this[each.value].id
  route_table_id = aws_route_table.private[each.value].id
}
