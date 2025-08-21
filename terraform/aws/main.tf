# module "network" {
#  source = "./modules/network"
# }

# module "compute" {
#  source = "./modules/compute"
#  ec2_ami = "ami-0f409bae3775dc8e5"
#  vpca_id = module.network.vpca_id
#  sn_vpca_pub1a = module.network.sn_vpca_pub1a
#  sn_vpca_pub1c = module.network.sn_vpca_pub1c
# }