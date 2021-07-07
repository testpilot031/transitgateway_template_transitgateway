variable "aws_region" {
  type = string
}
variable "aws_azs" {
  default = []
}
#
# VPC Subnet
#
#
variable "network_address_range" {
  default = "192.168.0.0/14"
}
variable "vpcs" {
  default = [
    { id = "inspection", cidr_block = "192.168.8.0/21", tags_Name = "inspection-vpc" },
    { id = "hoge01", cidr_block = "192.168.16.0/21", tags_Name = "hoge01-vpc" },
    { id = "hoge02", cidr_block = "192.168.24.0/21", tags_Name = "hoge02-vpc" },
    { id = "hoge03", cidr_block = "192.168.32.0/21", tags_Name = "hoge03-vpc" }
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
#
# RouteTable Route
#
#
variable "route_tables" {
  default = [
    { id = "main_hoge01-rt", vpc_id = "hoge01" },
    { id = "main_hoge03-rt", vpc_id = "hoge03" },
    { id = "inspection-rt_az1", vpc_id = "inspection" },
    { id = "inspection-rt_az2", vpc_id = "inspection" },
    { id = "firewall-rt", vpc_id = "inspection" },
    { id = "nat_tgw-rt", vpc_id = "hoge02" },
    { id = "igw_tgw-rt", vpc_id = "hoge02" },
  ]
}
variable "routes" {
  default = [
    { route_table_id = "main_hoge01-rt", id = "all_to_tgw_hoge01", cidr_block = "0.0.0.0/0", transit_gateway_id = "tokyo" },
    { route_table_id = "main_hoge03-rt", id = "all_to_tgw_hoge03", cidr_block = "0.0.0.0/0", transit_gateway_id = "tokyo" },
    { route_table_id = "inspection-rt_az1", id = "all_to_fw_inspection_az1", cidr_block = "0.0.0.0/0", fw_vpc_endpoint_subnet_id = "inspection_pri01" },
    { route_table_id = "inspection-rt_az2", id = "all_to_fw_inspection_az2", cidr_block = "0.0.0.0/0", fw_vpc_endpoint_subnet_id = "inspection_pri02" },
    { route_table_id = "firewall-rt", id = "all_to_tgw_inspection", cidr_block = "0.0.0.0/0", transit_gateway_id = "tokyo" },
    { route_table_id = "nat_tgw-rt", id = "all_to_ngw_hoge02", cidr_block = "0.0.0.0/0", nat_gateway_id = "example" },
    { route_table_id = "nat_tgw-rt", id = "some_to_tgw_hoge02_tx", cidr_block = "", transit_gateway_id = "tokyo" },
    { route_table_id = "igw_tgw-rt", id = "all_to_igw_hoge02", cidr_block = "0.0.0.0/0", gateway_id = "example" },
    { route_table_id = "igw_tgw-rt", id = "some_to_tgw_hoge02_pri", cidr_block = "", transit_gateway_id = "tokyo" }
  ]
}
variable "route_table_associations" {
  default = [
    { id = "1-1", subnet_id = "hoge01_pri01", route_table_id = "main_hoge01-rt" },
    { id = "1-2", subnet_id = "hoge01_pri02", route_table_id = "main_hoge01-rt" },
    { id = "1-3", subnet_id = "hoge01_tx01", route_table_id = "main_hoge01-rt" },
    { id = "1-4", subnet_id = "hoge01_tx02", route_table_id = "main_hoge01-rt" },

    { id = "2-1", subnet_id = "hoge02_pri01", route_table_id = "igw_tgw-rt" },
    { id = "2-2", subnet_id = "hoge02_pri01", route_table_id = "igw_tgw-rt" },
    { id = "2-3", subnet_id = "hoge02_tx01", route_table_id = "nat_tgw-rt" },
    { id = "2-4", subnet_id = "hoge02_tx01", route_table_id = "nat_tgw-rt" },

    { id = "3-1", subnet_id = "hoge03_pri01", route_table_id = "main_hoge03-rt" },
    { id = "3-2", subnet_id = "hoge03_pri02", route_table_id = "main_hoge03-rt" },
    { id = "3-3", subnet_id = "hoge03_tx01", route_table_id = "main_hoge03-rt" },
    { id = "3-4", subnet_id = "hoge03_tx02", route_table_id = "main_hoge03-rt" },

    { id = "4-1", subnet_id = "inspection_pri01", route_table_id = "firewall-rt" },
    { id = "4-2", subnet_id = "inspection_pri02", route_table_id = "firewall-rt" },
    { id = "4-3", subnet_id = "inspection_tx01", route_table_id = "inspection-rt_az1" },
    { id = "4-4", subnet_id = "inspection_tx02", route_table_id = "inspection-rt_az2" },
  ]
}
#
# Firewall
#
#
variable "firewall_endponts" {
  default = [
    { id = "inspection_pri01", vpc_id = "inspection", subnet_id = "inspection_pri01" },
    { id = "inspection_pri02", vpc_id = "inspection", subnet_id = "inspection_pri02" }
  ]
}

#
# transitgateway
#
#
variable "transitgateways" {
  default = [
    { id = "tokyo", asn = "64513" }
  ]
}
variable "transit_gateway_route_table_associations_attachment" {
  default = [
    { attachment_id = "hoge01-at", route_table_id = "inspection-rt" },
    { attachment_id = "inspection-at", route_table_id = "firewall-rt" },
    { attachment_id = "hoge03-at", route_table_id = "firewall-rt" },
    { attachment_id = "hoge02-at", route_table_id = "not_inspection-rt" }
  ]
}
variable "transitgateway_routetables" {
  default = [
    { id = "inspection-rt", transit_gateway_id = "tokyo" },
    { id = "firewall-rt", transit_gateway_id = "tokyo" },
    { id = "not_inspection-rt", transit_gateway_id = "tokyo" }
  ]
}
variable "vpc_attachments" {
  default = [
    { transit_gateway_id = "tokyo", id = "inspection-at", vpc_id = "inspection",
    subnet_ids = ["inspection_tx01", "inspection_tx02"], },
    { transit_gateway_id = "tokyo", id = "hoge01-at", vpc_id = "hoge01",
    subnet_ids = ["hoge01_tx01", "hoge01_tx02"], },
    { transit_gateway_id = "tokyo", id = "hoge02-at", vpc_id = "hoge02",
    subnet_ids = ["hoge02_tx01", "hoge02_tx02"], },
    { transit_gateway_id = "tokyo", id = "hoge03-at", vpc_id = "hoge03",
    subnet_ids = ["hoge03_tx01", "hoge03_tx02"], },
  ]
}

variable "transitgateway_routes" {
  default = [
    # destはvpcのIDから引きたい。"0.0.0.0/0"の場合わけをしたい
    # destdest_cidr かdest_vpcはどちらかを記載する
    { routetable_id = "inspection-rt", id = "inspection", dest_cidr = "0.0.0.0/0", attachment_id = "inspection-at" },
    { routetable_id = "firewall-rt", id = "firewall", dest_cidr = "0.0.0.0/0", attachment_id = "hoge02-at" },
    { routetable_id = "not_inspection-rt", id = "not_inspection_01",
    dest_cidr = "specified_in_dest_vpc_id", dest_vpc_id = "hoge01", attachment_id = "hoge01-at" },
    { routetable_id = "not_inspection-rt", id = "not_inspection_02",
    dest_cidr = "specified_in_dest_vpc_id", dest_vpc_id = "hoge03", attachment_id = "hoge03-at" }
  ]
}
