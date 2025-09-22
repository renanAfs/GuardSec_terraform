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
# Cria o Auto Scaling Group para as instâncias da aplicação.
# ------------------------------------------------------------------------------
module "compute" {
  source = "./modules/compute"

  project_name                = var.project_name
  private_subnet_ids          = module.network.private_subnet_ids
  web_server_sg_id            = module.network.web_server_sg_id
  alb_target_group_blue_arn   = module.network.alb_target_group_blue_arn
  alb_target_group_green_arn  = module.network.alb_target_group_green_arn
  instance_ami                = var.instance_ami
  instance_type               = var.instance_type # Free Tier: t2.micro
  db_instance_class           = var.db_instance_class
  db_sg_id                    = module.network.db_sg_id
  db_username                 = var.db_username
  db_password                 = var.db_password
}

# ------------------------------------------------------------------------------
# MÓDULO DE BANCO DE DADOS
# Cria o banco de dados RDS.
# ------------------------------------------------------------------------------
module "database" {
  source = "./modules/database"

  project_name      = var.project_name
  db_instance_class = var.db_instance_class # Free Tier: db.t2.micro
  db_username       = var.db_username
  db_password       = var.db_password
  private_subnet_ids = module.network.private_subnet_ids
  db_sg_id          = module.network.db_sg_id
}

# ------------------------------------------------------------------------------
# MÓDULO FORTINET
# Cria as instâncias EC2 para o FortiGate e FortiManager.
# ATENÇÃO: Requer AMIs da AWS Marketplace e licenças (NÃO É FREE TIER).
# ------------------------------------------------------------------------------
module "fortinet" {
  source = "./modules/fortinet"

  project_name      = var.project_name
  vpc_id            = module.network.security_vpc_id
  public_subnet_id  = module.network.security_public_subnet_id
  fortinet_sg_id    = module.network.fortinet_sg_id
  
  # Você precisa obter os IDs das AMIs do AWS Marketplace
  fortigate_ami   = var.fortigate_ami
  fortimanager_ami = var.fortimanager_ami
}

# ------------------------------------------------------------------------------
# MÓDULO ROUTE 53
# Cria a zona de DNS e os registros da aplicação.
# ------------------------------------------------------------------------------
module "route53" {
  source = "./modules/route53"

  project_name = var.project_name
  domain_name  = var.domain_name
  alb_dns_name = module.network.alb_dns_name
  alb_zone_id  = module.network.alb_zone_id
}

# ------------------------------------------------------------------------------
# MÓDULO DE MONITORAMENTO E CLOUDTRAIL
# Cria alarmes do CloudWatch e a trilha do CloudTrail.
# ------------------------------------------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  project_name       = var.project_name
  asg_name           = module.compute.asg_name
  db_instance_id     = module.database.db_instance_ids
  notification_topic_arn = try(module.monitoring.notification_topic_arn, "")
}

# ------------------------------------------------------------------------------
# MÓDULO CODEDEPLOY
# Configura o Blue/Green deployment para a aplicação.
# ------------------------------------------------------------------------------
module "codedeploy" {
  source = "./modules/codedeploy"

  project_name             = var.project_name
  asg_name                 = module.compute.asg_name
  alb_listener_arn         = module.network.alb_listener_arn
  blue_target_group_name   = module.network.alb_target_group_blue_name
  green_target_group_name  = module.network.alb_target_group_green_name
}

