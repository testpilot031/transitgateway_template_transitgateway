variable "vpcs" {
  default = [
    { id = "inspection", cidr_block = "192.168.8.0/21", tags_Name = "inspection" },
    { id = "hoge01", cidr_block = "192.168.16.0/21", tags_Name = "hoge01" },
    { id = "hoge02", cidr_block = "192.168.24.0/21", tags_Name = "hoge02" },
    { id = "hoge03", cidr_block = "192.168.32.0/21", tags_Name = "hoge03" }
  ]
}
variable "subnets" {
  default = [
    # 変数内で変数を呼び出せない。変数内で関数は呼び出せない
    # inspection
    { id = "inspection_pri01", tags_Name = "inspection_pri01", cidr_block = "192.168.10.0/24", vpc_id = "inspection",
    az_num = 0 },
    { id = "inspection_pri02", tags_Name = "inspection_pri02", cidr_block = "192.168.11.0/24", vpc_id = "inspection",
    az_num = 1 },
    { id = "inspection_tx01", tags_Name = "inspection_tx01", cidr_block = "192.168.15.224/28", vpc_id = "inspection",
    az_num = 0 },
    { id = "inspection_tx02", tags_Name = "inspection_tx02", cidr_block = "192.168.15.240/28", vpc_id = "inspection",
    az_num = 1 },
    # hoge01
    { id = "hoge01_pri01", tags_Name = "hoge01_pri01", cidr_block = "192.168.18.0/24", vpc_id = "hoge01", az_num = 0 },
    { id = "hoge01_pri02", tags_Name = "hoge01_pri02", cidr_block = "192.168.19.0/24", vpc_id = "hoge01", az_num = 1 },
    { id = "hoge01_tx01", tags_Name = "hoge01_tx01", cidr_block = "192.168.23.224/28", vpc_id = "hoge01", az_num = 0 },
    { id = "hoge01_tx02", tags_Name = "hoge01_tx02", cidr_block = "192.168.23.240/28", vpc_id = "hoge01", az_num = 1 },
    # hoge02
    { id = "hoge02_pri01", tags_Name = "hoge02_pri01", cidr_block = "192.168.26.0/24", vpc_id = "hoge02", az_num = 0 },
    { id = "hoge02_pri02", tags_Name = "hoge02_pri02", cidr_block = "192.168.27.0/24", vpc_id = "hoge02", az_num = 1 },
    { id = "hoge02_tx01", tags_Name = "hoge02_tx01", cidr_block = "192.168.31.224/28", vpc_id = "hoge02", az_num = 0 },
    { id = "hoge02_tx02", tags_Name = "hoge02_tx02", cidr_block = "192.168.31.240/28", vpc_id = "hoge02", az_num = 1 },
    # hoge03
    { id = "hoge03_pri01", tags_Name = "hoge03_pri01", cidr_block = "192.168.34.0/24", vpc_id = "hoge03", az_num = 0 },
    { id = "hoge03_pri02", tags_Name = "hoge03_pri02", cidr_block = "192.168.35.0/24", vpc_id = "hoge03", az_num = 1 },
    { id = "hoge03_tx01", tags_Name = "hoge03_tx01", cidr_block = "192.168.39.224/28", vpc_id = "hoge03", az_num = 0 },
    { id = "hoge03_tx02", tags_Name = "hoge03_tx02", cidr_block = "192.168.39.240/28", vpc_id = "hoge03", az_num = 1 },
  ]
}
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
  vpc      = true
  tags ={
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
variable "route_tables" {
  default = [
    { id = "main_hoge01-rt", vpc_id = "hoge01" },
    { id = "main_hoge03-rt", vpc_id = "hoge03" },
    { id = "inspection-rt", vpc_id = "inspection" },
    { id = "firewall-rt", vpc_id = "inspection" },
    { id = "nat_tgw-rt", vpc_id = "hoge02" },
    { id = "igw_tgw-rt", vpc_id = "hoge02" },
  ]
}
variable "routes" {
  default = [
    { route_table_id="main_hoge01-rt",id = "all_to_tgw_hoge01", cidr_block = "0.0.0.0/0", tgw_id = "tokyo" },
    { route_table_id="main_hoge03-rt",id = "all_to_tgw_hoge03", cidr_block = "0.0.0.0/0", tgw_id = "tokyo" },
    { route_table_id="inspection-rt",id = "all_to_tgw", cidr_block = "0.0.0.0/0", vpcep_id = "" },
    { route_table_id="firewall-rt",id = "all_to_tgw", cidr_block = "0.0.0.0/0", tgw_id = "tokyo" },
    { route_table_id="nat_tgw-rt",id = "all_to_tgw", cidr_block = "0.0.0.0/0", ngw_name = "example" },
    { route_table_id="igw_tgw-rt",id = "all_to_tgw", cidr_block = "0.0.0.0/0", igw_name = "example" },
  ]
}
variable "route_table_associations" {
  default = [
    { subnet_id = "hoge01_pri01", route_table_id = "main_hoge01-rt" },
    { subnet_id = "hoge01_pri02", route_table_id = "main_hoge01-rt" },
    { subnet_id = "hoge01_tx01", route_table_id = "main_hoge01-rt" },
    { subnet_id = "hoge01_tx02", route_table_id = "main_hoge01-rt" },

    { subnet_id = "hoge02_pri01", route_table_id = "igw_tgw-rt" },
    { subnet_id = "hoge02_pri01", route_table_id = "igw_tgw-rt" },
    { subnet_id = "hoge02_tx01", route_table_id = "nat_tgw-rt" },
    { subnet_id = "hoge02_tx01", route_table_id = "nat_tgw-rt" },

    { subnet_id = "hoge03_pri01", route_table_id = "main_hoge03-rt" },
    { subnet_id = "hoge03_pri02", route_table_id = "main_hoge03-rt" },
    { subnet_id = "hoge03_tx01", route_table_id = "main_hoge03-rt" },
    { subnet_id = "hoge03_tx02", route_table_id = "main_hoge03-rt" },

    { subnet_id = "inspection_pri01", route_table_id = "firewall-rt"},
    { subnet_id = "inspection_pri02", route_table_id = "firewall-rt"},
    { subnet_id = "inspection_tx01", route_table_id = "inspection-rt" },
    { subnet_id = "inspection_tx02", route_table_id = "inspection-rt" },
  ]
}
resource "aws_route_table" "example" {
  for_each          = { for rt in var.route_tables : rt.id => rt }
  vpc_id = aws_vpc.hoge["${each.value.vpc_id}"].id
  tags = {
    Name = "example"
  }
}
resource "aws_route" "hoge" {
  gateway_id             = aws_internet_gateway.example.id
  route_table_id         = aws_route_table.example.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "example" {
  for_each          = { for as in var.route_table_associations : as.id => as }
  subnet_id      = aws_subnet.hoge["${each.value.subnet_id}"].id
  route_table_id = each.value.route_table_id
}

# ====================
#
# Security Group
#
# ====================
resource "aws_security_group" "example" {
  vpc_id = aws_vpc.example.id
  name   = "example"
  tags = {
    Name = "example"
  }
}

# インバウンドルール(ssh接続用)
resource "aws_security_group_rule" "in_ssh" {
  security_group_id = aws_security_group.example.id
  type              = "ingress"
  cidr_blocks       = [aws_vpc.example.cidr_block]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}
# インバウンドルール(db用)
resource "aws_security_group_rule" "in_db" {
  security_group_id = aws_security_group.example.id
  type              = "ingress"
  cidr_blocks       = [aws_vpc.example.cidr_block]
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
}

# インバウンドルール(pingコマンド用)
resource "aws_security_group_rule" "in_icmp" {
  security_group_id = aws_security_group.example.id
  type              = "ingress"
  cidr_blocks       = [aws_vpc.example.cidr_block]
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
}

# アウトバウンドルール(全開放)
resource "aws_security_group_rule" "out_all" {
  security_group_id = aws_security_group.example.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}