resource "aws_networkfirewall_firewall" "example" {
  name                = "example"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.example.arn
  vpc_id              = aws_vpc.hoge["inspection"].id
  subnet_mapping {
    subnet_id = aws_subnet.hoge["inspection_pri01"].id
  }
  subnet_mapping {
    subnet_id = aws_subnet.hoge["inspection_pri02"].id
  }
  tags = {
    Name = "example"
  }
}
resource "aws_networkfirewall_firewall_policy" "example" {
  name = "example"

  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:pass"]
    # stateless_rule_group_reference {
    #   priority     = 1
    #   resource_arn = aws_networkfirewall_rule_group.example.arn
    # }
  }

  tags = {
    Name = "example"
  }
}
# resource "aws_networkfirewall_rule_group" "example" {
#   capacity = 100
#   name     = "example"
#   type     = "STATEFUL"
#   rule_group {
#     rules_source {
#       rules_source_list {
#         generated_rules_type = "ALLOWLIST"
#         target_types         = ["HTTP_HOST"]
#         targets              = ["test.example.com"]
#       }
#     }
#   }
#   tags = {
#     Name = "example"
#   }
# }

data "aws_vpc_endpoint" "firewall" {
  for_each = { for fwep in var.firewall_endponts : fwep.id => fwep }
  vpc_id   = aws_vpc.hoge["${each.value.vpc_id}"].id
  id = lookup({ for sync_state in tolist(aws_networkfirewall_firewall.example.firewall_status[0].sync_states) : sync_state.attachment[0].subnet_id => sync_state.attachment[0].endpoint_id
  }, aws_subnet.hoge["${each.value.subnet_id}"].id, null)
  tags = {
    "AWSNetworkFirewallManaged" = "true"
    "Firewall"                  = aws_networkfirewall_firewall.example.arn
  }
  depends_on = [aws_networkfirewall_firewall.example]
}
