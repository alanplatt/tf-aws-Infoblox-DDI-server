resource "aws_vpc" "infoblox" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "infoblox"
  }
}

resource "aws_internet_gateway" "infoblox" {
  vpc_id = aws_vpc.infoblox.id
  tags = {
    Name = "infoblox"
  }
}

resource "aws_subnet" "infoblox_mgmt" {
  vpc_id     = aws_vpc.infoblox.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "infoblox-mgmt"
  }
}

resource "aws_default_route_table" "infoblox" {
  default_route_table_id = aws_vpc.infoblox.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.infoblox.id
  }

  tags = {
    Name = "infoblox"
  }
}

resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "infoblox"
  }
}

module "infoblox" {
  source      = "./modules/infoblox-tf-template"
  aws_region  = "eu-west-1"
  key_pair    = aws_key_pair.apsystems.id
  name_prefix = terraform.workspace

  vpc_id         = aws_vpc.infoblox.id
  mgmt_subnet_id = aws_subnet.infoblox_mgmt.id

  management_ip  = "10.0.1.104"
  management_ip2 = "10.0.1.105"

  include_public_ip = true
}


