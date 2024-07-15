resource "aws_route_table" "rt_custom_internet" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  #map anythong to the gateway
    gateway_id = aws_internet_gateway.ig_custom.id


  }


  tags = {
    "Name" : "rt_custome_internet"
  }
}