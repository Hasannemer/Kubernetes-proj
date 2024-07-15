#This block defines an AWS subnet resource named "public_subnet" using the aws_subnet 
#ensures that ips inside this subnet are able to communicate with the internet 
#to met eks requirements at least two avz are needed
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true


#these tags are essential for load balancers
  tags = {
    "Name"                      = "public-10.0.1.0-eu-central-1a"
    "kubernetes.io/cluster/my_eks_cluster" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}




resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                      = "public-10.0.2.0-eu-central-1b"
    "kubernetes.io/cluster/my_eks_cluster" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}



#The automatic public IP assignment ensures that instances in this subnet are accessible
#from the internet if proper routing and security group rules are also configured.

#This setting indicates whether instances launched in the subnet should have public
#IP addresses automatically assigned. When set to true, instances launched in this 
#subnet will have public IP addresses.


# resource "aws_subnet" "private-subnet_a" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.0.0/20"
#   availability_zone = "eu-central-1a"

#   tags = {
#     "Name"                            = "private-eu-central-1a"
#     "kubernetes.io/role/internal-elb" = "1"
#     "kubernetes.io/cluster/demo"      = "owned"
#   }
# }

# resource "aws_subnet" "private-subnet_a" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.16.0/20"
#   availability_zone = "eu-central-1b"

#   tags = {
#     "Name"                            = "private-eu-central-1b"
#     "kubernetes.io/role/internal-elb" = "1"
#     "kubernetes.io/cluster/demo"      = "owned"
#   }
# }

# resource "aws_subnet" "public_subnet_a" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.32.0/20"
#   availability_zone       = "eu-central-1a"
#   map_public_ip_on_launch = true

#   tags = {
#     "Name"                       = "public-eu-central-1a"
#     "kubernetes.io/role/elb"     = "1"
#     "kubernetes.io/cluster/demo" = "owned"
#   }
# }

# resource "aws_subnet" "public_subnet_b" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.48.0/20"
#   availability_zone       = "eu-central-1b"
#   map_public_ip_on_launch = true

#   tags = {
#     "Name"                       = "public-eu-central-1b"
#     "kubernetes.io/role/elb"     = "1"
#     "kubernetes.io/cluster/my_eks_cluster" = "owned"
#   }
# }