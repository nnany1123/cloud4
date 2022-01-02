
provider "aws" {

  region = var.region

}


resource "aws_vpc" "default" {
  cidr_block           = "${var.region_numeral}.${var.cidr_numeral}.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.region_name}-${var.vpc_name}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "igw-${var.vpc_name}"
  }
}


resource "aws_nat_gateway" "nat" {
  count = length(var.availability_zones_without_b)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_internet_gateway.default]

  tags = {
    Name = "NAT-GW${count.index}-${var.vpc_name}"
  }

}

resource "aws_eip" "nat" {
  # Count value should be same with that of aws_nat_gateway because all nat will get elastic ip
  count = length(var.availability_zones_without_b)
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_subnet" "public" {
  count  = length(var.availability_zones_without_b)
  vpc_id = aws_vpc.default.id

  cidr_block        = "${var.region_numeral}.${var.cidr_numeral}.${var.cidr_numeral_public[count.index]}.0/24"
  availability_zone = element(var.availability_zones_without_b, count.index)


  map_public_ip_on_launch = true

  tags = {
    Name = "public${count.index}-${var.vpc_name}"


  }
}

# Route Table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "publicrt-${var.vpc_name}"
  }
}


# Route Table Association for public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones_without_b)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}



#### PRIVATE SUBNETS
# Subnet will use cidr with /20 -> The number of available IP is 4,096  (Including reserved ip from AWS)
resource "aws_subnet" "private" {
  count  = var.private_subnet # 가용영역 수 만큼 생성
  vpc_id = aws_vpc.default.id

  cidr_block        = "${var.region_numeral}.${var.cidr_numeral}.${var.cidr_numeral_private[count.index]}.0/24" #위와 같음.
  availability_zone = element(var.availability_zones_without_b, count.index) # 요것도 결국 가용영역 생긴만큼 순서대로 할당.

  tags = { #태그는 걍 표시라서 문법아님.
    Name               = "private${count.index}-${var.vpc_name}"
    Network            = "Private"
  }
}

# Route Table for private subnets
resource "aws_route_table" "private" {
  count  = length(var.availability_zones_without_b)
  vpc_id = aws_vpc.default.id

  route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }

  tags = {
    Name    = "private${count.index}rt-${var.vpc_name}"
    Network = "Private"

  }
}


# Route Table Association for private subnets
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones_without_b)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

#sg

resource "aws_security_group" "manage-ec2-sg" {
  name = "manage-ec2-sg"
  vpc_id = aws_vpc.default.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

   }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks      = ["0.0.0.0/0"]

  }
}




# tgw 테스트용 EC2
resource "aws_instance" "Bastion Host" {
  ami = "ami-0263588f2531a56bd" 
  instance_type = "t2.micro"
  key_name = var.key_pair
  vpc_security_group_ids = [aws_security_group.manage-ec2-sg.id]

  user_data       = data.template_file.user_data.rendered
  subnet_id              = aws_subnet.public[0].id
  tags = {
    Name = "Bastion Host"
  }

}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
  vars = {
    region_name = var.region_name
    vpc_name = var.vpc_name
  }
}


#### tgw 연결용 PRIVATE SUBNETS 생성
resource "aws_subnet" "private-tgw" {
  count  = var.private_subnet_tgw
  vpc_id = aws_vpc.default.id

  cidr_block        = "${var.region_numeral}.${var.cidr_numeral}.${var.cidr_numeral_private_tgw[count.index]}.0/24" #위와 같음.
  availability_zone = element(var.availability_zones_without_b, count.index) # 요것도 결국 가용영역 생긴만큼 순서대로 할당.

  tags = {
    Name               = "private-tgw${count.index}-${var.vpc_name}"
    Network            = "Private"
  }
}

# tgw 연결용 Route Table for private subnets
resource "aws_route_table" "private-tgw" {
  count  = length(var.availability_zones_without_b)
  vpc_id = aws_vpc.default.id

  route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }

  tags = {
    Name    = "private-tgw"
    Network = "Private"

  }
}


# tgw 연결용 Route Table Association for private subnets
resource "aws_route_table_association" "private-tgw" {
  count          = length(var.availability_zones_without_b)
  subnet_id      = element(aws_subnet.private-tgw.*.id, count.index)
  route_table_id = element(aws_route_table.private-tgw.*.id, count.index)
}






# TGW 생성

resource "aws_ec2_transit_gateway" "test-tgw" {


  description                     = "test-transit-gateway"
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "test-transit-gateway"
  }
}




# tgw 연결 vpc 연결
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  subnet_ids                                      = flatten([aws_subnet.private-tgw.*.id])
  transit_gateway_id                              = aws_ec2_transit_gateway.test-tgw.id
  vpc_id                                          = aws_vpc.default.id

  depends_on = [
    "aws_ec2_transit_gateway.test-tgw",
    "aws_subnet.private-tgw"
  ]
}


resource "aws_route" "to-trgw" {

  route_table_id         = aws_route_table.public.id
  transit_gateway_id     = aws_ec2_transit_gateway.test-tgw.id
  destination_cidr_block = var.destination_cidr

}


# peering

data "aws_caller_identity" "seoul" {
}

data "aws_region" "seoul" {
}

# accept it in the singapore account.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "example" {


  transit_gateway_attachment_id = var.peer_att.id
  tags = {
    Name = "tgw-peering-example"
    Side = "Acceptor"
  }
}

# tgw 기본 RT 데이터 소스
data "aws_ec2_transit_gateway_route_table" "peer_rt" {
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }
  depends_on = [
    "aws_ec2_transit_gateway.test-tgw"
  ]
}

# 경로 설정
resource "aws_ec2_transit_gateway_route" "example" {
  destination_cidr_block         = "20.0.0.0/8"
  transit_gateway_attachment_id  = var.peer_att.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.peer_rt.id
  depends_on = [
    "data.aws_ec2_transit_gateway_route_table.peer_rt",
    "aws_ec2_transit_gateway_peering_attachment_accepter.example"
  ]
}


resource "aws_route" "to-trgw-peer" {

  route_table_id         = aws_route_table.public.id
  transit_gateway_id     = aws_ec2_transit_gateway.test-tgw.id
  destination_cidr_block = "20.0.0.0/8"

}