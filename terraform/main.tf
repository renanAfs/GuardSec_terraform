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

# ------------------------------------------------------------------------------
# SERVIÇOS ADICIONAIS
# ------------------------------------------------------------------------------

# Cria uma trilha do CloudTrail para monitorar as chamadas de API
resource "aws_cloudtrail" "main_trail" {
  name                          = "${var.project_name}-trail"
  s3_bucket_name                = aws_s3_bucket.trail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
}

resource "aws_s3_bucket" "trail_bucket" {
  bucket = "${var.project_name}-trail-logs-${random_string.bucket_suffix.result}"
  # Em 2025, a AWS pode exigir a propriedade do objeto como "BucketOwnerEnforced"
  object_lock_enabled = false
  lifecycle {
    prevent_destroy = false
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}