# ====================
#
# VPC
#
# ====================
resource "aws_vpc" "hoge" {
  # ここでfor_each 内のvpc.idとすることで、特定のvpcを指定する時に
  # aws_vpc.hoge["${each.value.vpc_id}"].idと指定できるようになる
  for_each             = { for vpc in var.vpcs : vpc.id => vpc }
  cidr_block           = each.value.cidr_block
  enable_dns_support   = true # DNS解決を有効化
  enable_dns_hostnames = true # DNSホスト名を有効化
  tags = {
    Name = each.value.tags_Name
  }
}
resource "aws_subnet" "hoge" {
  for_each          = { for subnet in var.subnets : subnet.id => subnet }
  cidr_block        = each.value.cidr_block
  availability_zone = var.aws_azs[each.value.az_num]
  vpc_id            = aws_vpc.hoge["${each.value.vpc_id}"].id
  # trueにするとインスタンスにパブリックIPアドレスを自動的に割り当ててくれる
  map_public_ip_on_launch = false
  tags = {
    Name = each.value.tags_Name
  }
}
# ====================
#
# NAT Gateway
#
# ====================
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.example.id
  subnet_id     = aws_subnet.hoge["hoge02_pri01"].id
  tags = {
    Name = "gw NAT"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.example]
}
# ====================
#
# Elastic IP
#
# ====================
resource "aws_eip" "example" {
  vpc = true
  tags = {
    Name = "example_nat_gateway_eip"
  }
}
# ====================
#
# Internet Gateway
#
# ====================
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.hoge["hoge02"].id
  tags = {
    Name = "example"
  }
}

# ====================
#
# Route Table
#
# ====================

resource "aws_route_table" "hoge" {
  for_each = { for rt in var.route_tables : rt.id => rt }
  vpc_id   = aws_vpc.hoge["${each.value.vpc_id}"].id
  tags = {
    Name = "${each.value.id}"
  }
}
resource "aws_route" "hoge" {
  for_each                  = { for route in var.routes : route.id => route }
  egress_only_gateway_id    = lookup(each.value, "egress_only_gateway_id", null)
  gateway_id                = lookup(each.value, "gateway_id", null) != null ? aws_internet_gateway.example.id : null
  instance_id               = lookup(each.value, "instance_id", null)
  nat_gateway_id            = lookup(each.value, "nat_gateway_id", null) != null ? aws_nat_gateway.example.id : null
  network_interface_id      = lookup(each.value, "network_interface_id", null)
  transit_gateway_id        = lookup(each.value, "transit_gateway_id", null) != null ? aws_ec2_transit_gateway.hoge["${each.value.transit_gateway_id}"].id : null
  vpc_endpoint_id           = lookup(each.value, "fw_vpc_endpoint_subnet_id", null) != null ? data.aws_vpc_endpoint.firewall["${each.value.fw_vpc_endpoint_subnet_id}"].id : null
  vpc_peering_connection_id = lookup(each.value, "vpc_peering_connection_id", null)
  route_table_id            = aws_route_table.hoge["${each.value.route_table_id}"].id
  destination_cidr_block    = (each.value.cidr_block != "" ? each.value.cidr_block : var.network_address_range)
  depends_on                = [aws_route_table.hoge]
}

resource "aws_route_table_association" "example" {
  for_each       = { for as in var.route_table_associations : as.id => as }
  subnet_id      = aws_subnet.hoge["${each.value.subnet_id}"].id
  route_table_id = aws_route_table.hoge["${each.value.route_table_id}"].id
}

# ====================
#
# Security Group
#
# ====================
resource "aws_security_group" "hoge" {
  for_each = { for vpc in var.vpcs : vpc.id => vpc }
  vpc_id   = aws_vpc.hoge["${each.value.id}"].id
  name     = "example"
  tags = {
    Name = "example"
  }
}

# インバウンドルール(ssh接続用)
resource "aws_security_group_rule" "in_ssh" {
  for_each          = { for vpc in var.vpcs : vpc.id => vpc }
  security_group_id = aws_security_group.hoge["${each.value.id}"].id
  type              = "ingress"
  cidr_blocks       = [var.network_address_range]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}


# インバウンドルール(pingコマンド用)
resource "aws_security_group_rule" "in_icmp" {
  for_each          = { for vpc in var.vpcs : vpc.id => vpc }
  security_group_id = aws_security_group.hoge["${each.value.id}"].id
  type              = "ingress"
  cidr_blocks       = [var.network_address_range]
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
}

# アウトバウンドルール(全開放)
resource "aws_security_group_rule" "out_all" {
  for_each          = { for vpc in var.vpcs : vpc.id => vpc }
  security_group_id = aws_security_group.hoge["${each.value.id}"].id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}
# ====================
#
# endpoint
#
# ====================
# ssm, ssmmessage, ec2message はEC2をssmで中に入るために必要な設定
resource "aws_vpc_endpoint" "ssm" {
  for_each          = { for instance in var.instances : instance.id => instance }
  vpc_id            = aws_vpc.hoge["${each.value.vpc_id}"].id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.hoge["${each.value.subnet_id}"].id]
  security_group_ids = [
    aws_security_group.hoge["${each.value.vpc_id}"].id,
  ]
  private_dns_enabled = true

}
resource "aws_vpc_endpoint" "ssmmessage" {
  for_each          = { for instance in var.instances : instance.id => instance }
  vpc_id            = aws_vpc.hoge["${each.value.vpc_id}"].id
  service_name      = "com.amazonaws.${var.aws_region}.ssmmessage"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.hoge["${each.value.subnet_id}"].id]
  security_group_ids = [
    aws_security_group.hoge["${each.value.vpc_id}"].id,
  ]
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "ec2message" {
  for_each          = { for instance in var.instances : instance.id => instance }
  vpc_id            = aws_vpc.hoge["${each.value.vpc_id}"].id
  service_name      = "com.amazonaws.${var.aws_region}.ec2message"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.hoge["${each.value.subnet_id}"].id]
  security_group_ids = [
    aws_security_group.hoge["${each.value.vpc_id}"].id,
  ]
  private_dns_enabled = true
}
