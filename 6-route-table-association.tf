#associate the gateway to the route table
resource "aws_route_table_association" "rt_custom_internet_assoc_a" {
  route_table_id = aws_route_table.rt_custom_internet.id
  subnet_id = aws_subnet.public_subnet_a.id

}

resource "aws_route_table_association" "rt_custom_internet_assoc_b" {
  route_table_id = aws_route_table.rt_custom_internet.id
  subnet_id      = aws_subnet.public_subnet_b.id
}
