output vpc_id {
  value = aws_vpc.default.id
}
output cidr {
  value = aws_vpc.default.cidr_block
}
output public_subnet_ids {
  value = aws_subnet.private.*.id
}
output public_route_table_id {
  value = aws_route_table.public.id
}

output tgw {
  value = aws_ec2_transit_gateway.test-tgw.id
}
output tgw_route_table_id {
  value = data.aws_ec2_transit_gateway_route_table.peer_rt.id
}
output tgw_subnet {
  value = aws_subnet.private-tgw.*.id
}

output "account_id" {
  value = data.aws_caller_identity.seoul.account_id
}

output "seoul_region_name" {
  value = data.aws_region.seoul.name
}

output peer_att {
  value = aws_ec2_transit_gateway_peering_attachment_accepter.example
}