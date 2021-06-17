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
