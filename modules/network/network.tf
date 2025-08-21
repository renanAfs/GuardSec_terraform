# resource "aws_vpc" "vpca" {
#     cidr_block           = "10.0.0.0/16"
#     enable_dns_hostnames = "true"
# }



# resource "aws_subnet" "sn_vpca_pub1a" {
#     vpc_id                  = aws_vpc.vpca.id
#     cidr_block              = "10.0.1.0/24"
#     availability_zone       = "us-east-1a"
#     map_public_ip_on_launch = true
# }

# resource "aws_subnet" "sn_vpca_pub1c" {
#     vpc_id                  = aws_vpc.vpca.id
#     cidr_block              = "10.0.2.0/24"
#     availability_zone       = "us-east-1c"
#     map_public_ip_on_launch = true
# }


# resource "aws_internet_gateway" "igw_vpca" {
#     vpc_id = aws_vpc.vpca.id
# }

# resource "aws_route_table" "rt_sn_vpca_pub" {
#     vpc_id = aws_vpc.vpca.id

#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.igw_vpca.id
#     }
# }


# resource "aws_route_table_association" "rt_sn_vpca_pub_To_sn_vpca_pub1a" {
#   subnet_id      = aws_subnet.sn_vpca_pub1a.id
#   route_table_id = aws_route_table.rt_sn_vpca_pub.id
# }

# resource "aws_route_table_association" "rt_sn_vpca_pub_To_sn_vpca_pub1c" {
#   subnet_id      = aws_subnet.sn_vpca_pub1c.id
#   route_table_id = aws_route_table.rt_sn_vpca_pub.id
# }
