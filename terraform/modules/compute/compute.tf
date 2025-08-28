# modules/compute/main.tf

# -------------------------------------------------------------
# IAM Role para as Instâncias EC2
# -------------------------------------------------------------
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
    }]
  })
}

# Permite que as instâncias se conectem ao Systems Manager (bom para gerenciamento)
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}


# -------------------------------------------------------------
# Instâncias EC2 da Aplicação (4 no total)
# -------------------------------------------------------------
resource "aws_instance" "web_server" {
  count         = 4
  ami           = var.instance_ami
  instance_type = var.instance_type
  # Distribui as 4 instâncias pelas 2 subnets privadas
  subnet_id     = var.private_subnet_ids[count.index % 2]
  vpc_security_group_ids = [var.web_server_sg_id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.project_name}-web-${count.index + 1}"
    Project = var.project_name
  }
}

# Anexa as instâncias ao Target Group do Load Balancer
resource "aws_lb_target_group_attachment" "ec2-guardsec" {
  count            = 4
  target_group_arn = var.alb_target_group_arn
  target_id        = aws_instance.web_server[count.index].id
  port             = 80
}

# -------------------------------------------------------------
# Banco de Dados RDS Multi-AZ
# -------------------------------------------------------------
resource "aws_db_subnet_group" "dbmain" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "rds-main" {
  identifier           = "${var.project_name}-rds"
  allocated_storage    = 20 # Mínimo para Free Tier
  engine               = "postgres"
  engine_version       = "13.7"
  instance_class       = var.db_instance_class
  db_name              = "${var.project_name}db"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  multi_az             = true # Conforme o diagrama
  skip_final_snapshot  = true
}

# -------------------------------------------------------------
# AWS CodeDeploy
# -------------------------------------------------------------
resource "aws_codedeploy_app" "main" {
  compute_platform = "Server"
  name             = "${var.project_name}-app"
}

resource "aws_codedeploy_deployment_group" "main" {
  app_name              = aws_codedeploy_app.main.name
  deployment_group_name = "${var.project_name}-dg"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  ec2_tag_filter {
    key   = "Project"
    type  = "KEY_AND_VALUE"
    value = var.project_name
  }

  # Outras configurações como load balancer, triggers, etc. podem ser adicionadas aqui
}

resource "aws_iam_role" "codedeploy_role" {
  name = "${var.project_name}-codedeploy-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "codedeploy.amazonaws.com" },
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}