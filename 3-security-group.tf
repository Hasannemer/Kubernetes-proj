resource "aws_security_group" "sg_custom" {

 vpc_id = aws_vpc.custom_vpc.id

 #modify this later on to specify the allowed outbound traffic 
 egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]

 }
 #modify this later on to specify the allowed inbound traffic 
#  ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = ["89.187.217.204/32" , "94.187.18.5/32"]
#  }

 ingress{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

 }

 ingress{
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

 }

 ingress{
    from_port = 2379
    to_port = 2379
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

 tags = {
    "Name" = "sg_custom"

 }

 
}