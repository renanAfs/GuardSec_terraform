# modules/fortinet/main.tf

# -----------------------------------------------------------------------------------
# AVISO IMPORTANTE SOBRE CUSTOS
# -----------------------------------------------------------------------------------
# Os recursos da Fortinet (FortiGate, FortiManager) NÃO FAZEM PARTE do Free Tier da AWS.
# Eles exigem a compra de uma licença (BYOL) ou o uso de um modelo pago (PAYG)
# através do AWS Marketplace. As AMIs abaixo são apenas placeholders. Você precisa
# se inscrever no produto no Marketplace para obter os IDs de AMI corretos para sua região.
# -----------------------------------------------------------------------------------

resource "aws_instance" "fortigate_primary" {
  ami           = var.fortigate_ami
  instance_type = "t3.large" # Exemplo, verifique os requisitos da Fortinet
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [var.fortinet_sg_id]

  tags = {
    Name = "${var.project_name}-fortigate-primary"
  }
}

resource "aws_instance" "fortigate_secondary" {
  ami           = var.fortigate_ami
  instance_type = "t3.large"
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [var.fortinet_sg_id]

  tags = {
    Name = "${var.project_name}-fortigate-secondary"
  }
}

resource "aws_instance" "fortimanager" {
  ami           = var.fortimanager_ami
  instance_type = "t3.large"
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [var.fortinet_sg_id]

  tags = {
    Name = "${var.project_name}-fortimanager"
  }
}