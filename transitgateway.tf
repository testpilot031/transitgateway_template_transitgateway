resource "aws_ec2_transit_gateway" "this" {
  description                     = "!!! MUST delete in future !!!"
  amazon_side_asn                 = ""
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "disable"
  #vpn_ecmp_support                = var.enable_vpn_ecmp_support ? "enable" : "disable"
  dns_support = "enable"
  tags = {
    Name = "!!! MUST delete in future !!!"
  }
}
resource "aws_ec2_transit_gateway_route_table" "this" {
  transit_gateway_id = aws_ec2_transit_gateway.this[0].id
  tags = {
    Name = "!!! MUST delete in future !!!"
  }
}
resource "aws_ec2_transit_gateway_route" "example" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.example.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.example.association_default_route_table_id
  tags = {
    Name = "!!! MUST delete in future !!!"
  }
}
resource "aws_route" "this" {
  route_table_id         = each.key
  destination_cidr_block = each.value
  transit_gateway_id     = aws_ec2_transit_gateway.this[0].id
}
resource "aws_ec2_transit_gateway_route_table_association" "example" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.example.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[0].id
}