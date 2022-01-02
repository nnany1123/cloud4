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
