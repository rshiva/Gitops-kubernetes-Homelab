locals {
  name_prefix = "${var.project_name}-${var.env}"
}
resource "aws_vpc" "main" {
  region = var.region
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = { Name = "${local.name_prefix}-vpc"}
}

resource "aws_subnet" "public"{
  count = length(var.public_subnets)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
      Name = "${local.name_prefix}-public-${count.index + 1}"
      "kubernetes.io/role/elb" = "1" #ALB controller discovers public subnets
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }

}

resource "aws_subnet" "private"{
  count = length(var.private_subnets)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
tags = {
    Name = "${local.name_prefix}-private-${count.index + 1}"
    "kubernetes.io/role/elb" = "1" #ALB controller discovers public subnets
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_internet_gateway" "igw"{
  vpc_id = aws_vpc.main.id
  tags = { Name = "${local.name_prefix}-igw"}
}

# Route tables
resource "aws_route_table" "public_rt"{
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${local.name_prefix}-public-rt"}
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${local.name_prefix}-private-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_security_group" "allow_tls" {
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${local.name_prefix}-security-group"}
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4"{
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 8001
  ip_protocol       = "tcp"
  to_port           = 8001
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_lb" "lb"{
  internal           = false
  name = "${local.name_prefix}-lb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.allow_tls.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = false # Set to true for prod

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "${local.name_prefix}-lb"
  #   enabled = true
  # }
}

# Nat Gateway and EIP

resource "aws_eip" "nat_eip"{
  domain = "vpc"
  depends_on = [aws_internet_gateway.igw]
  tags = {
      Name = "${local.name_prefix}-nat-eip"
    }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id # dev: single NAT GW
                                          # prod: one per AZ for HA

  tags = {
    Name = "${local.name_prefix}-nat-gw"
  }
  depends_on = [aws_internet_gateway.igw]
}

# resource "aws_nat_gateway_eip_association" "nat-eip-assocation" {
#   allocation_id  = aws_eip.nat-eip.id
#   nat_gateway_id = aws_nat_gateway.nat.id
# }
