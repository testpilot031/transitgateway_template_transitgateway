# ====================
#
# Outputs
#
# ====================
output "firewall_status" {
  value = { for sync_state in tolist(aws_networkfirewall_firewall.example.firewall_status[0].sync_states) : sync_state.attachment[0].subnet_id => sync_state.attachment[0].endpoint_id
  }
  #value = [for sync_state in tolist(aws_networkfirewall_firewall.example.firewall_status[0].sync_states) : sync_state.attachment[0].endpoint_id if sync_state.attachment[0].subnet_id == "subnet-015198f4a65048ef5"]

}
output "firewall_status1" {
  value = [for sync_state in tolist(aws_networkfirewall_firewall.example.firewall_status[0].sync_states) : sync_state.attachment[0]]
}

output "firewall_status2" {
  value = lookup({ for sync_state in tolist(aws_networkfirewall_firewall.example.firewall_status[0].sync_states) : sync_state.attachment[0].subnet_id => sync_state.attachment[0].endpoint_id
  }, aws_subnet.hoge["inspection_tx01"].id, null)
}
output "firewall_status3" {
  value = keys({ for sync_state in tolist(aws_networkfirewall_firewall.example.firewall_status[0].sync_states) : sync_state.attachment[0].subnet_id => sync_state.attachment[0].endpoint_id
  })
}
output "aws_subnet" {
  value = aws_subnet.hoge["inspection_pri01"].id
}
# output "aws_vpc_endpoint" {
#   value = data.aws_vpc_endpoint.firewall["inspection_tx01"]
# }
