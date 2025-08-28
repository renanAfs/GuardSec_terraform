# modules/network/main.tf

# -------------------------------------------------------------
# VPC Principal (Aplicação)
# -------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-main-vpc"
  }
}

# Subnets Públicas
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

# Subnets Privadas
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 101}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Rota para a Internet nas Subnets Públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway para as Subnets Privadas
resource "aws_eip" "nat" {
  count = 2
  domain   = "vpc"
}

resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "${var.project_name}-nat-gw-${count.index + 1}"
  }
  depends_on = [aws_internet_gateway.main]
}

# Rota para o NAT Gateway nas Subnets Privadas
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
  tags = {
    Name = "${var.project_name}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# -------------------------------------------------------------
# Application Load Balancer e WAF
# -------------------------------------------------------------
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_wafv2_web_acl" "main" {
  name        = "${var.project_name}-waf-acl"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }

  // Adicione regras gerenciadas pela AWS (ex: Core Rule Set)
  rule {
    name     = "AWS-Managed-Core-Rule-Set"
    priority = 1
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "aws-managed-rules"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "main-waf-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# -------------------------------------------------------------
# VPC de Segurança e Peering
# -------------------------------------------------------------
resource "aws_vpc" "security" {
  cidr_block = "172.16.0.0/16"
  tags = {
    Name = "${var.project_name}-security-vpc"
  }
}

resource "aws_subnet" "security_public" {
  vpc_id                  = aws_vpc.security.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-security-public-subnet"
  }
}

resource "aws_vpc_peering_connection" "main_to_security" {
  peer_vpc_id   = aws_vpc.security.id
  vpc_id        = aws_vpc.main.id
  auto_accept   = true
  tags = {
    Name = "Peering: ${aws_vpc.main.tags.Name} <-> ${aws_vpc.security.tags.Name}"
  }
}

# -------------------------------------------------------------
# Security Groups
# -------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Permite tráfego HTTP/HTTPS para o ALB"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_server" {
  name        = "${var.project_name}-web-sg"
  description = "Permite tráfego do ALB para os web servers"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Permite tráfego dos web servers para o RDS"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 5432 // Exemplo para PostgreSQL
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server.id]
  }
}

resource "aws_security_group" "fortinet" {
  name        = "${var.project_name}-fortinet-sg"
  description = "SG para instâncias Fortinet"
  vpc_id      = aws_vpc.security.id
  # Adicione aqui as regras necessárias para gerenciar o FortiGate/FortiManager
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # RESTRINJA PARA SEU IP EM PRODUÇÃO
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------------------------------------------
# Outros
# -------------------------------------------------------------
data "aws_availability_zones" "available" {}