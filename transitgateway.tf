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
    dest_cidr = "specified_in_dest_vpc_id",dest_vpc_id = "hoge01", attachment_id = "hoge01-at" },
    { routetable_id = "not_inspection-rt", id = "not_inspection_02", 
    dest_cidr = "specified_in_dest_vpc_id",dest_vpc_id = "hoge03", attachment_id = "hoge03-at" }
  ]
}


resource "aws_ec2_transit_gateway" "hoge" {
  for_each                        = { for tgw in var.transitgateways : tgw.id => tgw }
  description                     = "!!! MUST delete in future, This is TEST ^^/ !!!"
  amazon_side_asn                 = each.value.asn
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  auto_accept_shared_attachments  = "disable"
  #vpn_ecmp_support                = var.enable_vpn_ecmp_support ? "enable" : "disable"
  dns_support = "enable"
  tags = {
    Name = "MUST_delete_in_future"
  }
}
resource "aws_ec2_transit_gateway_route_table" "hoge" {
  for_each           = { for rt in var.transitgateway_routetables : rt.id => rt }
  transit_gateway_id = aws_ec2_transit_gateway.hoge["${each.value.transit_gateway_id}"].id
  tags = {
    Name = "!!! MUST delete in future !!!"
  }
}
resource "aws_ec2_transit_gateway_route" "example" {
  for_each                       = { for route in var.transitgateway_routes : route.id => route }
  # destination_cidr_block をcidrで指定するかvpcのセグメントで指定するかを場合分けする 
  destination_cidr_block         = (each.value.dest_cidr == "specified_in_dest_vpc_id" ? aws_vpc.hoge["${each.value.dest_vpc_id}"].cidr_block : each.value.dest_cidr)
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hoge["${each.value.attachment_id}"].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hoge["${each.value.routetable_id}"].id
}
resource "aws_ec2_transit_gateway_route_table_association" "example" {
  for_each           = { for ac in var.transit_gateway_route_table_associations_attachment : ac.attachment_id => ac }
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hoge["${each.value.attachment_id}"].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hoge["${each.value.route_table_id}"].id
}
resource "aws_ec2_transit_gateway_vpc_attachment" "hoge" {
  for_each           = { for at in var.vpc_attachments : at.id => at }
  subnet_ids         = [for subnet_id in each.value.subnet_ids : aws_subnet.hoge["${subnet_id}"].id]
  transit_gateway_id = aws_ec2_transit_gateway.hoge["${each.value.transit_gateway_id}"].id
  vpc_id             = aws_vpc.hoge["${each.value.vpc_id}"].id
}
