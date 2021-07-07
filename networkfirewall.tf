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
    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.example.arn
    }
  }
  tags = {
    Name = "example"
  }
}
resource "aws_networkfirewall_rule_group" "example" {
  capacity    = 1
  name        = "permitt-any"
  description = "Permits all traffic"
  type        = "STATEFUL"
  rule_group {
    rules_source {
      stateful_rule {
        action = "PASS"
        header {
          source           = "ANY"
          source_port      = "ANY"
          destination      = "ANY"
          destination_port = "ANY"
          protocol         = "IP"
          direction        = "ANY"
        }
        rule_option {
          keyword = "sid:1"
        }
      }
    }
  }
  tags = {
    Name = "example"
  }
}
# firewallのlog をcloudwatchに流すための設定
resource "aws_networkfirewall_logging_configuration" "example" {
  firewall_arn = aws_networkfirewall_firewall.example.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.example.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}
# firewallのlog をcloudwatchに流すための設定
resource "aws_cloudwatch_log_group" "example" {
  name              = "firewall-log"
  retention_in_days = 14
}
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
