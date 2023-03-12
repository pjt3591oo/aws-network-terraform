# ======= VPC =======
resource "aws_vpc" "vpc_prod" {
  cidr_block  = "10.12.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "prod-vpc"
  }
}

# ======= Subnet =======
resource "aws_subnet" "pub-subnet1" {
  vpc_id      = aws_vpc.vpc_prod.id
  cidr_block  = "10.12.1.0/24" # 10.12.1.0 ~ 10.12.1.255
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "pub-subnet1"
  }
}
resource "aws_subnet" "pub-subnet2" {
  vpc_id      = aws_vpc.vpc_prod.id
  cidr_block  = "10.12.2.0/24" # 10.12.2.0 ~ 10.12.2.255
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
    Name = "pub-subnet2"
  }
}
resource "aws_subnet" "prv-subnet1" {
  vpc_id      = aws_vpc.vpc_prod.id
  cidr_block  = "10.12.3.0/24" # 10.12.3.0 ~ 10.12.3.255
  map_public_ip_on_launch = false # private subnet은 해당 설정값을 false로 둔다
  availability_zone = "us-east-1a"
  tags = {
    Name = "prv-subnet1"
  }
}
resource "aws_subnet" "prv-subnet2" {
  vpc_id      = aws_vpc.vpc_prod.id
  cidr_block  = "10.12.4.0/24" # 10.12.4.0 ~ 10.12.4.255
  map_public_ip_on_launch = false # private subnet은 해당 설정값을 false로 둔다
  availability_zone = "us-east-1b"
  tags = {
    Name = "prv-subnet2"
  }
}

// ====== Internet Gateway ======
resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.vpc_prod.id
  tags = {
    Name = "prod-igw"
  }
}

// ====== NAT Gateway ======
// NAT는 EIP가 필요하므로 EIP 정의
resource "aws_eip" "prod-eip" {
  vpc      = true
  tags = {
    Name = "prod-eip"
  }
}

// NAT에 EIP 연결
// NAT는 public subnect에 존재해야 한다.
resource "aws_nat_gateway" "prod-natgw" {
  allocation_id = aws_eip.prod-eip.id
  subnet_id     = aws_subnet.pub-subnet1.id
  tags = {
    Name = "prod-natgw"
  }
}

// ====== 라우팅 테이블 ======
// 라우팅 테이블이 존재하는 VPC 정의
// public subnet을 위한 라우팅 테이블의 0.0.0.0/0은 Internet Gateway를 향한다.
// private subnet을 위한 라이팅 테이블의 0.0.0.0/0은 NAT Gateway를 향한다.
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc_prod.id
  # route를 정의하지 않고 aws_route로 정의할 수 있다.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.prod-igw.id}"
  }
  tags = {
    Name = "public-route-tabler"  
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc_prod.id
  # route를 정의하지 않고 aws_route로 정의할 수 있다.
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.prod-natgw.id}"
  }
  tags = {
    Name = "private-route-tabler"  
  }
}

// 만약 aws_route_table 리소스에 route {cidr_block = "" gateway_id = ""}가 없다면 
# resource "aws_route" "public-route" {
#   route_table_id              = aws_route_table.public-route-table.id
#   destination_cidr_block      = "0.0.0.0/0"
#   nat_gateway_id              = aws_internet_gateway.prod-igw.id
# }
# resource "aws_route" "private-route" {
#   route_table_id              = aws_route_table.private-route-table.id
#   destination_cidr_block      = "0.0.0.0/0"
#   nat_gateway_id              = aws_internet_gateway.prod-natgw.id
# }

// 서브넷 라우팅 테이블 정의
locals {
  pub_subnet_ids = ["${aws_subnet.pub-subnet1.id}", "${aws_subnet.pub-subnet2.id}"]
  prv_subnet_ids = ["${aws_subnet.prv-subnet1.id}", "${aws_subnet.prv-subnet2.id}"]
}
resource "aws_route_table_association" "public-route-table_association" {
  count = length(local.pub_subnet_ids)
  subnet_id      = local.pub_subnet_ids[count.index]
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "private-route-table_association" {
  count = length(local.prv_subnet_ids)
  subnet_id      = local.prv_subnet_ids[count.index]
  route_table_id = aws_route_table.private-route-table.id
}