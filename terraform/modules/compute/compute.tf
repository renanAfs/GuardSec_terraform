# modules/compute/main.tf

# PROCURA DINAMICAMENTE A AMI MAIS RECENTE DO AMAZON LINUX 2023
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -------------------------------------------------------------
# Launch Template para o Auto Scaling Group
# -------------------------------------------------------------
resource "aws_launch_template" "web_server" {
  name_prefix   = "${var.project_name}-lt-"
  # ALTERADO AQUI: Usa a AMI encontrada dinamicamente
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [var.web_server_sg_id]

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
# -------------------------------------------------------------
resource "aws_autoscaling_group" "web_server" {
  name_prefix = "${var.project_name}-asg-"
  min_size             = 2
  max_size             = 4
  desired_capacity     = 4
  vpc_zone_identifier  = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  target_group_arns = [var.alb_target_group_blue_arn, var.alb_target_group_green_arn]

  lifecycle {
    create_before_destroy = true
  }

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