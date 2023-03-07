provider "aws" {
  access_key                  = var.access_key
  secret_key                  = var.secret_key
  region                      = "us-east-1"
  s3_use_path_style           = false
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    apigatewayv2   = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    es             = "http://localhost:4566"
    elasticache    = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    route53        = "http://localhost:4566"
    s3             = "http://s3.localhost.localstack.cloud:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}


# ======= VPC =======
resource "aws_vpc" "vpc_dev" {
  cidr_block  = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "dev-vpc"
  }
}

# ======= Subnmet =======
resource "aws_subnet" "pub-subnet1" {
  vpc_id      = aws_vpc.vpc_dev.id
  cidr_block  = "10.10.1.0/24" # 10.10.1.0 ~ 10.10.1.255
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "pub-subnet1"
  }
}
resource "aws_subnet" "pub-subnet2" {
  vpc_id      = aws_vpc.vpc_dev.id
  cidr_block  = "10.10.2.0/24" # 10.10.2.0 ~ 10.10.2.255
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
    Name = "pub-subnet2"
  }
}
resource "aws_subnet" "prv-subnet1" {
  vpc_id      = aws_vpc.vpc_dev.id
  cidr_block  = "10.10.3.0/24" # 10.10.3.0 ~ 10.10.3.255
  map_public_ip_on_launch = false # private subnet은 해당 설정값을 false로 둔다
  availability_zone = "us-east-1a"
  tags = {
    Name = "prv-subnet1"
  }
}
resource "aws_subnet" "prv-subnet2" {
  vpc_id      = aws_vpc.vpc_dev.id
  cidr_block  = "10.10.4.0/24" # 10.10.4.0 ~ 10.10.4.255
  map_public_ip_on_launch = false # private subnet은 해당 설정값을 false로 둔다
  availability_zone = "us-east-1b"
  tags = {
    Name = "prv-subnet2"
  }
}

// ====== Internet Gateway ======
resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.vpc_dev.id
    tags = {
    Name = "dev-igw"
  }
}

// ====== NAT Gateway ======
// NAT는 EIP가 필요하므로 EIP 정의
resource "aws_eip" "dev-eip" {
  vpc      = true
  tags = {
    Name = "dev-eip"
  }
}

// NAT에 EIP 연결
// NAT는 public subnect에 존재해야 한다.
resource "aws_nat_gateway" "dev-natgw" {
  allocation_id = aws_eip.dev-eip.id
  subnet_id     = aws_subnet.pub-subnet1.id
  tags = {
    Name = "dev-natgw"
  }
}

// ====== 라우팅 테이블 ======
// 라우팅 테이블이 존재하는 VPC 정의
// public subnet을 위한 라우팅 테이블의 0.0.0.0/0은 Internet Gateway를 향한다.
// private subnet을 위한 라이팅 테이블의 0.0.0.0/0은 NAT Gateway를 향한다.
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc_dev.id
  # route를 정의하지 않고 aws_route로 정의할 수 있다.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.dev-igw.id}"
  }
  tags = {
    Name = "public-route-tabler"  
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc_dev.id
  # route를 정의하지 않고 aws_route로 정의할 수 있다.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.dev-natgw.id}"
  }
  tags = {
    Name = "private-route-tabler"  
  }
}

// 만약 aws_route_table 리소스에 route {cidr_block = "" gateway_id = ""}가 없다면 
# resource "aws_route" "public-route" {
#   route_table_id              = aws_route_table.public-route-table.id
#   destination_cidr_block      = "0.0.0.0/0"
#   nat_gateway_id              = aws_internet_gateway.dev-igw.id
# }
# resource "aws_route" "private-route" {
#   route_table_id              = aws_route_table.private-route-table.id
#   destination_cidr_block      = "0.0.0.0/0"
#   nat_gateway_id              = aws_internet_gateway.dev-natgw.id
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