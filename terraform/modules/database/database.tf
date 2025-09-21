# terraform/modules/database/database.tf

resource "aws_db_instance" "default" {
  count                = 2
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.db_instance_class
  identifier           = "${var.project_name}-db-${count.index}"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_sg_id]
  skip_final_snapshot  = true
  multi_az             = true
}
