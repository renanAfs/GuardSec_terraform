# main.tf

provider "aws" {
  region = var.aws_region
}

# ------------------------------------------------------------------------------
# MÓDULO DE REDE
# Cria as VPCs, subnets, peering, Load Balancer, WAF, Security Groups, etc.
# ------------------------------------------------------------------------------
module "network" {
  source = "./modules/network"

  project_name = var.project_name
  aws_region   = var.aws_region
  domain_name = var.domain_name
  subdomain    = var.subdomain
}

# ------------------------------------------------------------------------------
# MÓDULO DE COMPUTAÇÃO
# Cria o Auto Scaling Group para as instâncias e o banco de dados RDS.
# ------------------------------------------------------------------------------
module "compute" {
  source = "./modules/compute"

  project_name = var.project_name
  private_subnet_ids     = module.network.private_subnet_ids
  web_server_sg_id       = module.network.web_server_sg_id
  db_sg_id               = module.network.db_sg_id
  alb_target_group_arn   = module.network.alb_target_group_arn
  instance_ami           = var.instance_ami
  instance_type          = var.instance_type # Free Tier: t2.micro
  db_instance_class      = var.db_instance_class # Free Tier: db.t2.micro
  db_username            = var.db_username
  db_password            = var.db_password
}

# ------------------------------------------------------------------------------
# MÓDULO FORTINET
# Cria as instâncias EC2 para o FortiGate e FortiManager.
# ATENÇÃO: Requer AMIs da AWS Marketplace e licenças (NÃO É FREE TIER).
# ------------------------------------------------------------------------------
# module "fortinet" {
#   source = "./modules/fortinet"

#   project_name      = var.project_name
#   vpc_id            = module.network.security_vpc_id
#   public_subnet_id  = module.network.security_public_subnet_id
#   fortinet_sg_id    = module.network.fortinet_sg_id
  
#   # Você precisa obter os IDs das AMIs do AWS Marketplace
#   fortigate_ami   = var.fortigate_ami
#   fortimanager_ami = var.fortimanager_ami
# }
