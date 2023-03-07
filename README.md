# 테라폼으로 이해하는 AWS 네트워크 구성

## 구성요소

클라우드의 네트워크는 다음과 같은 모습을 가진다.

![](./resource/architecture.png)

### Internet Gateway 

VPC에서 네트워크 통신이 가능하게 함

외부 네트워크와 접점부분.

public subnet이라고 부름

route table에서 연결할 수 있다.

### NAT Gateway

NAT Gateway는 네트워크 주소변환 서비스

NAT Gateway는 public Subnet에 위치

외부 서비스에서 private network의 인스턴스로 접근이 불가능하도록 하고, private network에서 외부 서비스에 접근할 수 있도록 하는 서비스

route table을 통해서 연결할 수 있다.

### VPC(virtual private cloud)

가상의 네트워크 망

### Subnet

* public Subnet

외부와 통신이 가능. nat instance를 통하여 private subnet과 통신가능

* private Subnet

외부와 차단됨. 오직 다른 서브넷과의 연결만 허용. 대표적으로 디비 인스턴스를 private subnet에 배치한다.

외부 네트워크 망과 inbound/outbound를 허용하지 않음

### route table

라우팅이 설정되지 않은 서브넷은 정상적으로 외부와 통신이 되지 않는다.

public subnet의 0.0.0.0/0은 IGW로 설정

private subnet의 0.0.0.0/0은 NAT Gateway로 설정


### NACL(Network ACL)

서브넷을 들어오고 나가는 트래픽 제어. VPC를 위한 선택적 보안계층

서브넷은 한 개의 NACL만 가질 수 있다.

Stateless

### Security Group

인스턴스 수준에서 동작

Statefull

---

## 네트워크 구성하기

해당 예시에서는 NACL과 Security group은 별도로 정의하지 않는다.

![](./resource/archi-sample.png)

가장 위의 VPC부터 dev, stage, prod 네트워크 대역

### dev

* vpc

```
CIDR: 10.10.0.0/16 => 10.10.0.0 ~ 10.10.255.255
```

* subnet

```
public-subnet1
  CIDR: 10.10.2.0/24 => 10.10.1.0 ~ 10.10.1.255
  AZ: a
```

```
public-subnet2
  CIDR: 10.10.2.0/24 => 10.10.2.0 ~ 10.10.2.255
  AZ: b
```

```
private-subnet1
  CIDR: 10.10.3.0/24 => 10.10.3.0 ~ 10.10.3.255
  AZ: a
```

```
private-subnet2
  CIDR: 10.10.4.0/24 => 10.10.4.0 ~ 10.10.4.255
  AZ: b
```

* NAT Gateway

public-subnet1에 위치

### stage

* vpc

```
CIDR: 10.11.0.0/16 => 10.11.0.0 ~ 10.11.255.255
```

* subnet

```
public-subnet1
  CIDR: 10.11.2.0/24 => 10.11.1.0 ~ 10.11.1.255
  AZ: a
```

```
public-subnet2
  CIDR: 10.11.2.0/24 => 10.11.2.0 ~ 10.11.2.255
  AZ: b
```

```
private-subnet1
  CIDR: 10.11.3.0/24 => 10.11.3.0 ~ 10.11.3.255
  AZ: a
```

```
private-subnet2
  CIDR: 10.11.4.0/24 => 10.11.4.0 ~ 10.11.4.255
  AZ: b
```

* NAT Gateway

public-subnet1에 위치

### prod

* vpc

```
CIDR: 10.12.0.0/16 => 10.12.0.0 ~ 10.12.255.255
```

* subnet

```
public-subnet1
  CIDR: 10.12.2.0/24 => 10.12.1.0 ~ 10.12.1.255
  AZ: a
```

```
public-subnet2
  CIDR: 10.12.2.0/24 => 10.12.2.0 ~ 10.12.2.255
  AZ: b
```

```
private-subnet1
  CIDR: 10.12.3.0/24 => 10.12.3.0 ~ 10.12.3.255
  AZ: a
```

```
private-subnet2
  CIDR: 10.12.4.0/24 => 10.12.4.0 ~ 10.12.4.255
  AZ: b
```

* NAT Gateway

public-subnet1에 위치

## 수행

### localstack 실행 & 환경변수

```bash
$ localstack start
```

* .env

```bash
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"
```

aws_secret.tf는 aws 접속을 위한 환경변수 정보를 가진다. 여기서는 .gitignore로 관리하지 않지만 aws, db 접속같은 중요 정보는 gitignore로 관리한다.

### 네트워크 생성

* dev

```
$ cd terraform/dev/network

$ terraform init

$ terraform plan

$ terraform apply
```

* stage


```
$ cd terraform/stage/network

$ terraform init

$ terraform plan

$ terraform apply
```

* prod

```
$ cd terraform/prod/network

$ terraform init

$ terraform plan

$ terraform apply
```

### eip 조회

```bash
$ aws --endpoint-url http://localhost:4566 ec2 describe-addresses | jq

{
  "Addresses": [
    {
      "InstanceId": "",
      "PublicIp": "127.226.197.20",
      "AllocationId": "eipalloc-e165c6e3",
      "AssociationId": "eipassoc-0b3558db",
      "Domain": "vpc",
      "NetworkInterfaceId": "eni-b4d234df",
      "NetworkInterfaceOwnerId": "000000000000",
      "PrivateIpAddress": "10.103.6.201",
      "Tags": [
        {
          "Key": "Name",
          "Value": "dev-eip"
        }
      ]
    },
    {
      "InstanceId": "",
      "PublicIp": "127.12.185.176",
      "AllocationId": "eipalloc-57cdb40e",
      "AssociationId": "eipassoc-d3fda428",
      "Domain": "vpc",
      "NetworkInterfaceId": "eni-21fb0b9f",
      "NetworkInterfaceOwnerId": "000000000000",
      "PrivateIpAddress": "10.90.248.112",
      "Tags": [
        {
          "Key": "Name",
          "Value": "stage-eip"
        }
      ]
    },
    {
      "InstanceId": "",
      "PublicIp": "127.199.1.47",
      "AllocationId": "eipalloc-198dee4f",
      "AssociationId": "eipassoc-11d730ce",
      "Domain": "vpc",
      "NetworkInterfaceId": "eni-0d17dd46",
      "NetworkInterfaceOwnerId": "000000000000",
      "PrivateIpAddress": "10.226.190.108",
      "Tags": [
        {
          "Key": "Name",
          "Value": "prod-eip"
        }
      ]
    }
  ]
}
```

### vpc 조회

```bash
$ aws --endpoint-url http://localhost:4566 ec2 describe-vpcs | jq

{
  "Vpcs": [
    {
      "CidrBlock": "172.31.0.0/16",
      "DhcpOptionsId": "dopt-7a8b9c2d",
      "State": "available",
      "VpcId": "vpc-c4480a63",
      "OwnerId": "000000000000",
      "InstanceTenancy": "default",
      "Ipv6CidrBlockAssociationSet": [],
      "CidrBlockAssociationSet": [
        {
          "AssociationId": "vpc-cidr-assoc-a8be538f",
          "CidrBlock": "172.31.0.0/16",
          "CidrBlockState": {
            "State": "associated"
          }
        }
      ],
      "IsDefault": true,
      "Tags": []
    },
    {
      "CidrBlock": "10.10.0.0/16",
      "DhcpOptionsId": "dopt-7a8b9c2d",
      "State": "available",
      "VpcId": "vpc-8287c4b6",
      "OwnerId": "000000000000",
      "InstanceTenancy": "default",
      "Ipv6CidrBlockAssociationSet": [],
      "CidrBlockAssociationSet": [
        {
          "AssociationId": "vpc-cidr-assoc-f56fb443",
          "CidrBlock": "10.10.0.0/16",
          "CidrBlockState": {
            "State": "associated"
          }
        }
      ],
      "IsDefault": false,
      "Tags": [
        {
          "Key": "Name",
          "Value": "dev-vpc"
        }
      ]
    },
    {
      "CidrBlock": "10.11.0.0/16",
      "DhcpOptionsId": "dopt-7a8b9c2d",
      "State": "available",
      "VpcId": "vpc-908dc97d",
      "OwnerId": "000000000000",
      "InstanceTenancy": "default",
      "Ipv6CidrBlockAssociationSet": [],
      "CidrBlockAssociationSet": [
        {
          "AssociationId": "vpc-cidr-assoc-5ee03fd5",
          "CidrBlock": "10.11.0.0/16",
          "CidrBlockState": {
            "State": "associated"
          }
        }
      ],
      "IsDefault": false,
      "Tags": [
        {
          "Key": "Name",
          "Value": "stage-vpc"
        }
      ]
    },
    {
      "CidrBlock": "10.12.0.0/16",
      "DhcpOptionsId": "dopt-7a8b9c2d",
      "State": "available",
      "VpcId": "vpc-618ee704",
      "OwnerId": "000000000000",
      "InstanceTenancy": "default",
      "Ipv6CidrBlockAssociationSet": [],
      "CidrBlockAssociationSet": [
        {
          "AssociationId": "vpc-cidr-assoc-1c4741b7",
          "CidrBlock": "10.12.0.0/16",
          "CidrBlockState": {
            "State": "associated"
          }
        }
      ],
      "IsDefault": false,
      "Tags": [
        {
          "Key": "Name",
          "Value": "prod-vpc"
        }
      ]
    }
  ]
}
```

### subnet 조회

```bash
$ aws --endpoint-url http://localhost:4566 ec2 describe-subnets| jq

{
  "Subnets": [
    {
      "AvailabilityZone": "us-east-1a",
      "AvailabilityZoneId": "use1-az6",
      "AvailableIpAddressCount": 4091,
      "CidrBlock": "172.31.0.0/20",
      "DefaultForAz": true,
      "MapPublicIpOnLaunch": true,
      "State": "available",
      "SubnetId": "subnet-58f10b81",
      "VpcId": "vpc-c4480a63",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-58f10b81",
      "Ipv6Native": false
    },
    {
      "AvailabilityZone": "us-east-1a",
      "AvailabilityZoneId": "use1-az6",
      "AvailableIpAddressCount": 251,
      "CidrBlock": "10.10.3.0/24",
      "DefaultForAz": false,
      "MapPublicIpOnLaunch": false,
      "State": "available",
      "SubnetId": "subnet-79c2a9c2",
      "VpcId": "vpc-8287c4b6",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "Tags": [
        {
          "Key": "Name",
          "Value": "prv-subnet1"
        }
      ],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-79c2a9c2",
      "Ipv6Native": false,
      "PrivateDnsNameOptionsOnLaunch": {
        "HostnameType": "ip-name"
      }
    },
    {
      "AvailabilityZone": "us-east-1a",
      "AvailabilityZoneId": "use1-az6",
      "AvailableIpAddressCount": 250,
      "CidrBlock": "10.10.1.0/24",
      "DefaultForAz": false,
      "MapPublicIpOnLaunch": true,
      "State": "available",
      "SubnetId": "subnet-372ec52c",
      "VpcId": "vpc-8287c4b6",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "Tags": [
        {
          "Key": "Name",
          "Value": "pub-subnet1"
        }
      ],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-372ec52c",
      "Ipv6Native": false,
      "PrivateDnsNameOptionsOnLaunch": {
        "HostnameType": "ip-name"
      }
    },
    {
      "AvailabilityZone": "us-east-1a",
      "AvailabilityZoneId": "use1-az6",
      "AvailableIpAddressCount": 251,
      "CidrBlock": "10.11.3.0/24",
      "DefaultForAz": false,
      "MapPublicIpOnLaunch": false,
      "State": "available",
      "SubnetId": "subnet-6faf587d",
      "VpcId": "vpc-908dc97d",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "Tags": [
        {
          "Key": "Name",
          "Value": "prv-subnet1"
        }
      ],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-6faf587d",
      "Ipv6Native": false,
      "PrivateDnsNameOptionsOnLaunch": {
        "HostnameType": "ip-name"
      }
    },
    {
      "AvailabilityZone": "us-east-1a",
      "AvailabilityZoneId": "use1-az6",
      "AvailableIpAddressCount": 250,
      "CidrBlock": "10.11.1.0/24",
      "DefaultForAz": false,
      "MapPublicIpOnLaunch": true,
      "State": "available",
      "SubnetId": "subnet-4e2c7cb1",
      "VpcId": "vpc-908dc97d",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "Tags": [
        {
          "Key": "Name",
          "Value": "pub-subnet1"
        }
      ],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-4e2c7cb1",
      "Ipv6Native": false,
      "PrivateDnsNameOptionsOnLaunch": {
        "HostnameType": "ip-name"
      }
    },
    {
      "AvailabilityZone": "us-east-1a",
      "AvailabilityZoneId": "use1-az6",
      "AvailableIpAddressCount": 250,
      "CidrBlock": "10.12.1.0/24",
      "DefaultForAz": false,
      "MapPublicIpOnLaunch": true,
      "State": "available",
      "SubnetId": "subnet-9850fae4",
      "VpcId": "vpc-618ee704",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "Tags": [
        {
          "Key": "Name",
          "Value": "pub-subnet1"
        }
      ],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-9850fae4",
      "Ipv6Native": false,
      "PrivateDnsNameOptionsOnLaunch": {
        "HostnameType": "ip-name"
      }
    },
    {
      "AvailabilityZone": "us-east-1a",
      "AvailabilityZoneId": "use1-az6",
      "AvailableIpAddressCount": 251,
      "CidrBlock": "10.12.3.0/24",
      "DefaultForAz": false,
      "MapPublicIpOnLaunch": false,
      "State": "available",
      "SubnetId": "subnet-bd167ebf",
      "VpcId": "vpc-618ee704",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "Tags": [
        {
          "Key": "Name",
          "Value": "prv-subnet1"
        }
      ],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-bd167ebf",
      "Ipv6Native": false,
      "PrivateDnsNameOptionsOnLaunch": {
        "HostnameType": "ip-name"
      }
    },
    {
      "AvailabilityZone": "us-east-1b",
      "AvailabilityZoneId": "use1-az1",
      "AvailableIpAddressCount": 4091,
      "CidrBlock": "172.31.16.0/20",
      "DefaultForAz": true,
      "MapPublicIpOnLaunch": true,
      "State": "available",
      "SubnetId": "subnet-470c89fe",
      "VpcId": "vpc-c4480a63",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-470c89fe",
      "Ipv6Native": false
    },
    {
      "AvailabilityZone": "us-east-1b",
      "AvailabilityZoneId": "use1-az1",
      "AvailableIpAddressCount": 251,
      "CidrBlock": "10.10.4.0/24",
      "DefaultForAz": false,
      "MapPublicIpOnLaunch": false,
      "State": "available",
      "SubnetId": "subnet-a343d5f9",
      "VpcId": "vpc-8287c4b6",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "Tags": [
        {
          "Key": "Name",
          "Value": "prv-subnet2"
        }
      ],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-a343d5f9",
      "Ipv6Native": false,
      "PrivateDnsNameOptionsOnLaunch": {
        "HostnameType": "ip-name"
      }
    },
    {
      "AvailabilityZone": "us-east-1b",
      "AvailabilityZoneId": "use1-az1",
      "AvailableIpAddressCount": 251,
      "CidrBlock": "10.10.2.0/24",
      "DefaultForAz": false,
      "MapPublicIpOnLaunch": true,
      "State": "available",
      "SubnetId": "subnet-72abae15",
      "VpcId": "vpc-8287c4b6",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "Tags": [
        {
          "Key": "Name",
          "Value": "pub-subnet2"
        }
      ],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-72abae15",
      "Ipv6Native": false,
      "PrivateDnsNameOptionsOnLaunch": {
        "HostnameType": "ip-name"
      }
    },
    {
      "AvailabilityZone": "us-east-1b",
      "AvailabilityZoneId": "use1-az1",
      "AvailableIpAddressCount": 251,
      "CidrBlock": "10.11.2.0/24",
      "DefaultForAz": false,
      "MapPublicIpOnLaunch": true,
      "State": "available",
      "SubnetId": "subnet-0a89aaed",
      "VpcId": "vpc-908dc97d",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "Tags": [
        {
          "Key": "Name",
          "Value": "pub-subnet2"
        }
      ],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-0a89aaed",
      "Ipv6Native": false,
      "PrivateDnsNameOptionsOnLaunch": {
        "HostnameType": "ip-name"
      }
    },
    {
      "AvailabilityZone": "us-east-1b",
      "AvailabilityZoneId": "use1-az1",
      "AvailableIpAddressCount": 251,
      "CidrBlock": "10.11.4.0/24",
      "DefaultForAz": false,
      "MapPublicIpOnLaunch": false,
      "State": "available",
      "SubnetId": "subnet-5ca4b2e1",
      "VpcId": "vpc-908dc97d",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "Tags": [
        {
          "Key": "Name",
          "Value": "prv-subnet2"
        }
      ],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-5ca4b2e1",
      "Ipv6Native": false,
      "PrivateDnsNameOptionsOnLaunch": {
        "HostnameType": "ip-name"
      }
    },
    {
      "AvailabilityZone": "us-east-1b",
      "AvailabilityZoneId": "use1-az1",
      "AvailableIpAddressCount": 251,
      "CidrBlock": "10.12.4.0/24",
      "DefaultForAz": false,
      "MapPublicIpOnLaunch": false,
      "State": "available",
      "SubnetId": "subnet-2cf0ba35",
      "VpcId": "vpc-618ee704",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "Tags": [
        {
          "Key": "Name",
          "Value": "prv-subnet2"
        }
      ],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-2cf0ba35",
      "Ipv6Native": false,
      "PrivateDnsNameOptionsOnLaunch": {
        "HostnameType": "ip-name"
      }
    },
    {
      "AvailabilityZone": "us-east-1b",
      "AvailabilityZoneId": "use1-az1",
      "AvailableIpAddressCount": 251,
      "CidrBlock": "10.12.2.0/24",
      "DefaultForAz": false,
      "MapPublicIpOnLaunch": true,
      "State": "available",
      "SubnetId": "subnet-db3e819e",
      "VpcId": "vpc-618ee704",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "Tags": [
        {
          "Key": "Name",
          "Value": "pub-subnet2"
        }
      ],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-db3e819e",
      "Ipv6Native": false,
      "PrivateDnsNameOptionsOnLaunch": {
        "HostnameType": "ip-name"
      }
    },
    {
      "AvailabilityZone": "us-east-1c",
      "AvailabilityZoneId": "use1-az2",
      "AvailableIpAddressCount": 4091,
      "CidrBlock": "172.31.32.0/20",
      "DefaultForAz": true,
      "MapPublicIpOnLaunch": true,
      "State": "available",
      "SubnetId": "subnet-11f73346",
      "VpcId": "vpc-c4480a63",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-11f73346",
      "Ipv6Native": false
    },
    {
      "AvailabilityZone": "us-east-1d",
      "AvailabilityZoneId": "use1-az4",
      "AvailableIpAddressCount": 4091,
      "CidrBlock": "172.31.48.0/20",
      "DefaultForAz": true,
      "MapPublicIpOnLaunch": true,
      "State": "available",
      "SubnetId": "subnet-bbcea871",
      "VpcId": "vpc-c4480a63",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-bbcea871",
      "Ipv6Native": false
    },
    {
      "AvailabilityZone": "us-east-1e",
      "AvailabilityZoneId": "use1-az3",
      "AvailableIpAddressCount": 4091,
      "CidrBlock": "172.31.64.0/20",
      "DefaultForAz": true,
      "MapPublicIpOnLaunch": true,
      "State": "available",
      "SubnetId": "subnet-25a695d1",
      "VpcId": "vpc-c4480a63",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-25a695d1",
      "Ipv6Native": false
    },
    {
      "AvailabilityZone": "us-east-1f",
      "AvailabilityZoneId": "use1-az5",
      "AvailableIpAddressCount": 4091,
      "CidrBlock": "172.31.80.0/20",
      "DefaultForAz": true,
      "MapPublicIpOnLaunch": true,
      "State": "available",
      "SubnetId": "subnet-c91cb757",
      "VpcId": "vpc-c4480a63",
      "OwnerId": "000000000000",
      "AssignIpv6AddressOnCreation": false,
      "Ipv6CidrBlockAssociationSet": [],
      "SubnetArn": "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-c91cb757",
      "Ipv6Native": false
    }
  ]
}

```

### internet gateway 조회

```shell
$ aws --endpoint-url http://localhost:4566 ec2 describe-internet-gateways | jq
{
  "InternetGateways": [
    {
      "Attachments": [
        {
          "State": "available",
          "VpcId": "vpc-8287c4b6"
        }
      ],
      "InternetGatewayId": "igw-18f8cc1e",
      "OwnerId": "000000000000",
      "Tags": [
        {
          "Key": "Name",
          "Value": "dev-igw"
        }
      ]
    },
    {
      "Attachments": [
        {
          "State": "available",
          "VpcId": "vpc-908dc97d"
        }
      ],
      "InternetGatewayId": "igw-18337a80",
      "OwnerId": "000000000000",
      "Tags": [
        {
          "Key": "Name",
          "Value": "stage-igw"
        }
      ]
    },
    {
      "Attachments": [
        {
          "State": "available",
          "VpcId": "vpc-618ee704"
        }
      ],
      "InternetGatewayId": "igw-24c612cd",
      "OwnerId": "000000000000",
      "Tags": [
        {
          "Key": "Name",
          "Value": "prod-igw"
        }
      ]
    }
  ]
}
```

### nat gateway 조회

```bash
$ aws --endpoint-url http://localhost:4566 ec2 describe-nat-gateways | jq
{
  "NatGateways": [
    {
      "CreateTime": "2023-03-07T09:57:42.069000+00:00",
      "NatGatewayAddresses": [
        {
          "AllocationId": "eipalloc-e165c6e3",
          "NetworkInterfaceId": "eni-b4d234df",
          "PrivateIp": "10.103.6.201",
          "PublicIp": "127.226.197.20"
        }
      ],
      "NatGatewayId": "nat-fc220cee5ed76407e",
      "State": "available",
      "SubnetId": "subnet-372ec52c",
      "VpcId": "vpc-8287c4b6",
      "Tags": [
        {
          "Key": "Name",
          "Value": "dev-natgw"
        }
      ],
      "ConnectivityType": "public"
    },
    {
      "CreateTime": "2023-03-07T09:58:48.900000+00:00",
      "NatGatewayAddresses": [
        {
          "AllocationId": "eipalloc-57cdb40e",
          "NetworkInterfaceId": "eni-21fb0b9f",
          "PrivateIp": "10.90.248.112",
          "PublicIp": "127.12.185.176"
        }
      ],
      "NatGatewayId": "nat-ea98c9becfb9224a8",
      "State": "available",
      "SubnetId": "subnet-4e2c7cb1",
      "VpcId": "vpc-908dc97d",
      "Tags": [
        {
          "Key": "Name",
          "Value": "stage-natgw"
        }
      ],
      "ConnectivityType": "public"
    },
    {
      "CreateTime": "2023-03-07T09:59:43.473000+00:00",
      "NatGatewayAddresses": [
        {
          "AllocationId": "eipalloc-198dee4f",
          "NetworkInterfaceId": "eni-0d17dd46",
          "PrivateIp": "10.226.190.108",
          "PublicIp": "127.199.1.47"
        }
      ],
      "NatGatewayId": "nat-b38b78c45cf7d9b92",
      "State": "available",
      "SubnetId": "subnet-9850fae4",
      "VpcId": "vpc-618ee704",
      "Tags": [
        {
          "Key": "Name",
          "Value": "prod-natgw"
        }
      ],
      "ConnectivityType": "public"
    }
  ]
}
```

### route table 조회

```bash
$ aws --endpoint-url http://localhost:4566 ec2 describe-route-tables | jq

{
  "RouteTables": [
    {
      "Associations": [
        {
          "Main": true,
          "RouteTableAssociationId": "rtbassoc-f3c34435",
          "RouteTableId": "rtb-329ac1c4",
          "AssociationState": {
            "State": "associated"
          }
        }
      ],
      "RouteTableId": "rtb-329ac1c4",
      "Routes": [
        {
          "DestinationCidrBlock": "172.31.0.0/16",
          "GatewayId": "local",
          "Origin": "CreateRouteTable",
          "State": "active"
        }
      ],
      "Tags": [],
      "VpcId": "vpc-c4480a63",
      "OwnerId": "000000000000"
    },
    {
      "Associations": [
        {
          "Main": true,
          "RouteTableAssociationId": "rtbassoc-164a3d94",
          "RouteTableId": "rtb-1a649d26",
          "AssociationState": {
            "State": "associated"
          }
        }
      ],
      "RouteTableId": "rtb-1a649d26",
      "Routes": [
        {
          "DestinationCidrBlock": "10.10.0.0/16",
          "GatewayId": "local",
          "Origin": "CreateRouteTable",
          "State": "active"
        }
      ],
      "Tags": [],
      "VpcId": "vpc-8287c4b6",
      "OwnerId": "000000000000"
    },
    {
      "Associations": [
        {
          "Main": false,
          "RouteTableAssociationId": "rtbassoc-fdeec104",
          "RouteTableId": "rtb-0417eb38",
          "SubnetId": "subnet-72abae15",
          "AssociationState": {
            "State": "associated"
          }
        },
        {
          "Main": false,
          "RouteTableAssociationId": "rtbassoc-7a662192",
          "RouteTableId": "rtb-0417eb38",
          "SubnetId": "subnet-372ec52c",
          "AssociationState": {
            "State": "associated"
          }
        }
      ],
      "RouteTableId": "rtb-0417eb38",
      "Routes": [
        {
          "DestinationCidrBlock": "10.10.0.0/16",
          "GatewayId": "local",
          "Origin": "CreateRouteTable",
          "State": "active"
        },
        {
          "DestinationCidrBlock": "0.0.0.0/0",
          "GatewayId": "igw-18f8cc1e",
          "Origin": "CreateRoute",
          "State": "active"
        }
      ],
      "Tags": [
        {
          "Key": "Name",
          "Value": "public-route-tabler"
        }
      ],
      "VpcId": "vpc-8287c4b6",
      "OwnerId": "000000000000"
    },
    {
      "Associations": [
        {
          "Main": false,
          "RouteTableAssociationId": "rtbassoc-de1ca2bd",
          "RouteTableId": "rtb-851b7db3",
          "SubnetId": "subnet-79c2a9c2",
          "AssociationState": {
            "State": "associated"
          }
        },
        {
          "Main": false,
          "RouteTableAssociationId": "rtbassoc-587d6e72",
          "RouteTableId": "rtb-851b7db3",
          "SubnetId": "subnet-a343d5f9",
          "AssociationState": {
            "State": "associated"
          }
        }
      ],
      "RouteTableId": "rtb-851b7db3",
      "Routes": [
        {
          "DestinationCidrBlock": "10.10.0.0/16",
          "GatewayId": "local",
          "Origin": "CreateRouteTable",
          "State": "active"
        },
        {
          "DestinationCidrBlock": "0.0.0.0/0"
        }
      ],
      "Tags": [
        {
          "Key": "Name",
          "Value": "private-route-tabler"
        }
      ],
      "VpcId": "vpc-8287c4b6",
      "OwnerId": "000000000000"
    },
    {
      "Associations": [
        {
          "Main": true,
          "RouteTableAssociationId": "rtbassoc-351566fe",
          "RouteTableId": "rtb-71b3c671",
          "AssociationState": {
            "State": "associated"
          }
        }
      ],
      "RouteTableId": "rtb-71b3c671",
      "Routes": [
        {
          "DestinationCidrBlock": "10.11.0.0/16",
          "GatewayId": "local",
          "Origin": "CreateRouteTable",
          "State": "active"
        }
      ],
      "Tags": [],
      "VpcId": "vpc-908dc97d",
      "OwnerId": "000000000000"
    },
    {
      "Associations": [
        {
          "Main": false,
          "RouteTableAssociationId": "rtbassoc-be5b6481",
          "RouteTableId": "rtb-28103b7b",
          "SubnetId": "subnet-0a89aaed",
          "AssociationState": {
            "State": "associated"
          }
        },
        {
          "Main": false,
          "RouteTableAssociationId": "rtbassoc-952b7697",
          "RouteTableId": "rtb-28103b7b",
          "SubnetId": "subnet-4e2c7cb1",
          "AssociationState": {
            "State": "associated"
          }
        }
      ],
      "RouteTableId": "rtb-28103b7b",
      "Routes": [
        {
          "DestinationCidrBlock": "10.11.0.0/16",
          "GatewayId": "local",
          "Origin": "CreateRouteTable",
          "State": "active"
        },
        {
          "DestinationCidrBlock": "0.0.0.0/0",
          "GatewayId": "igw-18337a80",
          "Origin": "CreateRoute",
          "State": "active"
        }
      ],
      "Tags": [
        {
          "Key": "Name",
          "Value": "public-route-tabler"
        }
      ],
      "VpcId": "vpc-908dc97d",
      "OwnerId": "000000000000"
    },
    {
      "Associations": [
        {
          "Main": false,
          "RouteTableAssociationId": "rtbassoc-ff3c0d97",
          "RouteTableId": "rtb-46162a84",
          "SubnetId": "subnet-6faf587d",
          "AssociationState": {
            "State": "associated"
          }
        },
        {
          "Main": false,
          "RouteTableAssociationId": "rtbassoc-7ef34c6b",
          "RouteTableId": "rtb-46162a84",
          "SubnetId": "subnet-5ca4b2e1",
          "AssociationState": {
            "State": "associated"
          }
        }
      ],
      "RouteTableId": "rtb-46162a84",
      "Routes": [
        {
          "DestinationCidrBlock": "10.11.0.0/16",
          "GatewayId": "local",
          "Origin": "CreateRouteTable",
          "State": "active"
        },
        {
          "DestinationCidrBlock": "0.0.0.0/0"
        }
      ],
      "Tags": [
        {
          "Key": "Name",
          "Value": "private-route-tabler"
        }
      ],
      "VpcId": "vpc-908dc97d",
      "OwnerId": "000000000000"
    },
    {
      "Associations": [
        {
          "Main": true,
          "RouteTableAssociationId": "rtbassoc-8c7a80bd",
          "RouteTableId": "rtb-6307a9af",
          "AssociationState": {
            "State": "associated"
          }
        }
      ],
      "RouteTableId": "rtb-6307a9af",
      "Routes": [
        {
          "DestinationCidrBlock": "10.12.0.0/16",
          "GatewayId": "local",
          "Origin": "CreateRouteTable",
          "State": "active"
        }
      ],
      "Tags": [],
      "VpcId": "vpc-618ee704",
      "OwnerId": "000000000000"
    },
    {
      "Associations": [
        {
          "Main": false,
          "RouteTableAssociationId": "rtbassoc-22f5aeb0",
          "RouteTableId": "rtb-c4fd37d6",
          "SubnetId": "subnet-9850fae4",
          "AssociationState": {
            "State": "associated"
          }
        },
        {
          "Main": false,
          "RouteTableAssociationId": "rtbassoc-01112b6f",
          "RouteTableId": "rtb-c4fd37d6",
          "SubnetId": "subnet-db3e819e",
          "AssociationState": {
            "State": "associated"
          }
        }
      ],
      "RouteTableId": "rtb-c4fd37d6",
      "Routes": [
        {
          "DestinationCidrBlock": "10.12.0.0/16",
          "GatewayId": "local",
          "Origin": "CreateRouteTable",
          "State": "active"
        },
        {
          "DestinationCidrBlock": "0.0.0.0/0",
          "GatewayId": "igw-24c612cd",
          "Origin": "CreateRoute",
          "State": "active"
        }
      ],
      "Tags": [
        {
          "Key": "Name",
          "Value": "public-route-tabler"
        }
      ],
      "VpcId": "vpc-618ee704",
      "OwnerId": "000000000000"
    },
    {
      "Associations": [
        {
          "Main": false,
          "RouteTableAssociationId": "rtbassoc-4cfe0211",
          "RouteTableId": "rtb-924f69e9",
          "SubnetId": "subnet-bd167ebf",
          "AssociationState": {
            "State": "associated"
          }
        },
        {
          "Main": false,
          "RouteTableAssociationId": "rtbassoc-f5673da9",
          "RouteTableId": "rtb-924f69e9",
          "SubnetId": "subnet-2cf0ba35",
          "AssociationState": {
            "State": "associated"
          }
        }
      ],
      "RouteTableId": "rtb-924f69e9",
      "Routes": [
        {
          "DestinationCidrBlock": "10.12.0.0/16",
          "GatewayId": "local",
          "Origin": "CreateRouteTable",
          "State": "active"
        },
        {
          "DestinationCidrBlock": "0.0.0.0/0"
        }
      ],
      "Tags": [
        {
          "Key": "Name",
          "Value": "private-route-tabler"
        }
      ],
      "VpcId": "vpc-618ee704",
      "OwnerId": "000000000000"
    }
  ]
}
```