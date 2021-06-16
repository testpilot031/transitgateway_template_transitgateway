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
    az = "us-east-2a" },
    { id = "inspection_pri02", tags_Name = "inspection_pri02", cidr_block = "192.168.11.0/24", vpc_id = "inspection",
    az = "us-east-2b" },
    { id = "inspection_tx01", tags_Name = "inspection_tx01", cidr_block = "192.168.15.224/28", vpc_id = "inspection",
    az = "us-east-2a" },
    { id = "inspection_tx02", tags_Name = "inspection_tx02", cidr_block = "192.168.15.240/28", vpc_id = "inspection",
    az = "us-east-2b" },
    # hoge01
    { id = "hoge01_pri01", tags_Name = "hoge01_pri01", cidr_block = "192.168.18.0/24", vpc_id = "hoge01", az = "us-east-2a" },
    { id = "hoge01_pri02", tags_Name = "hoge01_pri02", cidr_block = "192.168.19.0/24", vpc_id = "hoge01", az = "us-east-2b" },
    { id = "hoge01_tx01", tags_Name = "hoge01_tx01", cidr_block = "192.168.23.224/28", vpc_id = "hoge01", az = "us-east-2a" },
    { id = "hoge01_tx02", tags_Name = "hoge01_tx02", cidr_block = "192.168.23.240/28", vpc_id = "hoge01", az = "us-east-2b" },
    # hoge02
    { id = "hoge02_pri01", tags_Name = "hoge02_pri01", cidr_block = "192.168.18.0/24", vpc_id = "hoge02", az = "us-east-2a" },
    { id = "hoge02_pri02", tags_Name = "hoge02_pri02", cidr_block = "192.168.19.0/24", vpc_id = "hoge02", az = "us-east-2b" },
    { id = "hoge02_tx01", tags_Name = "hoge02_tx01", cidr_block = "192.168.23.224/28", vpc_id = "hoge02", az = "us-east-2a" },
    { id = "hoge02_tx02", tags_Name = "hoge02_tx02", cidr_block = "192.168.23.240/28", vpc_id = "hoge02", az = "us-east-2b" },
  ]
}
# ====================
#
# VPC
#
# ====================
resource "aws_vpc" "hoge-vpc" {
  # ここでfor_each 内のvpc.idとすることで、特定のvpcを指定する時に
  # aws_vpc.hoge-vpc["${each.value.vpc_id}"].idと指定できるようになる
  for_each             = { for vpc in var.vpcs : vpc.id => vpc }
  cidr_block           = each.value.cidr_block
  enable_dns_support   = true # DNS解決を有効化
  enable_dns_hostnames = true # DNSホスト名を有効化
  tags = {
    Name = each.value.tags_Name
  }
}
resource "aws_subnet" "hoge-subnet" {
  for_each          = { for subnet in var.subnets : subnet.id => subnet }
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  vpc_id            = aws_vpc.hoge-vpc["${each.value.vpc_id}"].id

  # trueにするとインスタンスにパブリックIPアドレスを自動的に割り当ててくれる
  map_public_ip_on_launch = false

  tags = {
    Name = each.value.tags_Name
  }
}
