# ====================
#
# Outputs
#
# ====================
output "alb_dns_name" {
  value = tomap({
    for v in aws_vpc.hoge : v.id => v
  })

}
