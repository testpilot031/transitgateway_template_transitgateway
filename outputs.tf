# ====================
#
# Outputs
#
# ====================
output "firewall_status" {
  value = aws_networkfirewall_firewall.example.firewall_status

}

# output "aws_vpc_endpoint" {
#   value=data.aws_vpc_endpoint.firewall
# }