# modules/compute/main.tf

# -------------------------------------------------------------
# Launch Template para o Auto Scaling Group
# Define a configuração das instâncias EC2
# -------------------------------------------------------------
resource "aws_launch_template" "web_server" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = var.instance_ami
  instance_type = var.instance_type
  
  # Associa o Security Group criado no módulo de rede
  vpc_security_group_ids = [var.web_server_sg_id]

  # Adicione aqui um script de User Data se precisar instalar
  # um servidor web ou sua aplicação no boot da instância.
  /*
  user_data = base64encode <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
  */

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project_name}-web-instance"
      Project = var.project_name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


# -------------------------------------------------------------
# Auto Scaling Group
# Gerencia a criação e o ciclo de vida das instâncias EC2
# -------------------------------------------------------------
resource "aws_autoscaling_group" "web_server" {
  name_prefix = "${var.project_name}-asg-"

  # Define o número de instâncias
  min_size             = 2
  max_size             = 4
  desired_capacity     = 4 # Inicia com 4 instâncias conforme o diagrama

  # Subnets onde o ASG pode lançar instâncias
  vpc_zone_identifier  = var.private_subnet_ids

  # Link para o Launch Template
  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  # Anexa as instâncias automaticamente ao Target Group do ALB
  target_group_arns = [var.alb_target_group_arn]

  # Garante que novas instâncias sejam criadas antes das antigas serem terminadas
  # durante uma atualização, para evitar downtime.
  lifecycle {
    create_before_destroy = true
  }

  # Tags que serão aplicadas às instâncias lançadas pelo ASG
  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "${var.project_name}-web-instance-asg"
    propagate_at_launch = true
  }
}


# -------------------------------------------------------------
# Banco de Dados RDS Multi-AZ
# (Nenhuma mudança nesta seção)
# -------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier           = "${var.project_name}-rds"
  allocated_storage    = 20 # Mínimo para Free Tier
  engine               = "postgres"
  engine_version       = "15.5" # Use uma versão recente
  instance_class       = var.db_instance_class
  db_name              = "${var.project_name}db"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  multi_az             = true # Conforme o diagrama
  skip_final_snapshot  = true
  # Habilita o backup automático para o Free Tier (7 dias de retenção)
  backup_retention_period = 7
}