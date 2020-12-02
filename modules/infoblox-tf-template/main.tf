resource "random_password" "admin_password" {
  length = 16
  special = false
}

data "aws_ami" "latest-infoblox-image" {
  most_recent = true
  owners      = ["057670693668"]

  filter {
    name = "name"
    values = ["Infoblox NIOS 8.2.1 359366 CP-V800 BYOL"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User Data Template
data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl")}"

  vars = {
    admin_password         = var.admin_password != "" ? var.admin_password : random_password.admin_password.result
    temp_license           = var.temp_license
    remote_console_enabled = var.remote_console_enabled
  }
}

# EC2 Instances
resource "aws_instance" "infoblox" {
  ami                  = data.aws_ami.latest-infoblox-image.id
  instance_type        = "c4.large"
  key_name             = var.key_pair != "" ? var.key_pair : null
  user_data            = data.template_file.user_data.rendered

  network_interface {
    network_interface_id = aws_network_interface.infoblox_mgmt.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.infoblox_mgmt2.id
    device_index         = 1
  }

  tags = merge(map("Name", "${var.name_prefix}Infoblox"), var.default_tags)
}

# Network Interfaces
resource "aws_network_interface" "infoblox_mgmt" {
  subnet_id                   = var.mgmt_subnet_id
  security_groups             = [aws_security_group.infoblox_mgmt_sg.id]
  private_ips                 = [var.management_ip]

  tags = merge(map("Name", "${var.name_prefix}infoblox_mgmt"), var.default_tags)
}

resource "aws_network_interface" "infoblox_mgmt2" {
  subnet_id                   = var.mgmt_subnet_id
  security_groups             = [aws_security_group.infoblox_mgmt_sg.id]
  private_ips                 = [var.management_ip2]

  tags = merge(map("Name", "${var.name_prefix}infoblox_mgmt2"), var.default_tags)
}

# ENI Data Sources
data "aws_network_interface" "infoblox_mgmt" {
  id = aws_network_interface.infoblox_mgmt.id
}

# Elastic IPs
resource "aws_eip" "infoblox_mgmt_ip" {
  count                     = var.include_public_ip == true ? 1 : 0
  vpc                       = true
  network_interface         = aws_network_interface.infoblox_mgmt2.id
  associate_with_private_ip = var.management_ip2

  tags = merge(map("Name", "${var.name_prefix}infoblox_mgmt"), var.default_tags)

  depends_on = [aws_instance.infoblox]
}

# Security Groups
resource "aws_security_group" "infoblox_mgmt_sg" {
  name        = "${var.name_prefix}-infoblox_mgmt_sg"
  description = "Allow inbound SSH and HTTPS trafic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}