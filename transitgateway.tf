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
  for_each = { for route in var.transitgateway_routes : route.id => route }
  # destination_cidr_block をcidrで指定するかvpcのセグメントで指定するかを場合分けする 
  destination_cidr_block         = (each.value.dest_cidr == "specified_in_dest_vpc_id" ? aws_vpc.hoge["${each.value.dest_vpc_id}"].cidr_block : each.value.dest_cidr)
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hoge["${each.value.attachment_id}"].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hoge["${each.value.routetable_id}"].id
}
resource "aws_ec2_transit_gateway_route_table_association" "example" {
  for_each                       = { for ac in var.transit_gateway_route_table_associations_attachment : ac.attachment_id => ac }
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hoge["${each.value.attachment_id}"].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hoge["${each.value.route_table_id}"].id
}
resource "aws_ec2_transit_gateway_vpc_attachment" "hoge" {
  for_each                                        = { for at in var.vpc_attachments : at.id => at }
  subnet_ids                                      = [for subnet_id in each.value.subnet_ids : aws_subnet.hoge["${subnet_id}"].id]
  transit_gateway_id                              = aws_ec2_transit_gateway.hoge["${each.value.transit_gateway_id}"].id
  vpc_id                                          = aws_vpc.hoge["${each.value.vpc_id}"].id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "${each.value.id}"
  }
}
