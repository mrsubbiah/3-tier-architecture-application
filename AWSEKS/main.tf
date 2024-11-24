provider "aws" {
  region = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

terraform {
  backend "s3" {
    bucket         = "bdiplus-statefile"             # Name of the S3 bucket you created
    key            = "terraform.tfstate"             # The key (path) within the bucket for the state file
    region         = "us-east-2"
    encrypt        = true                             # Enable encryption for the state file
    dynamodb_table = "terraform-lock"                 # The DynamoDB table used for state locking
  }
}


# Create a VPC
resource "aws_vpc" "bdiplusvpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "bdiplusvpc"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.bdiplusvpc.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "Pub Subnet ${count.index + 1}"
  }
}

 resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.bdiplusvpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Pri Subnet ${count.index + 1}"
  }
}

# Create a IGW
resource "aws_internet_gateway" "bdiplusvpc-igw" {
  vpc_id = aws_vpc.bdiplusvpc.id

  tags = {
    Name = "bdiplusvpc-igw"
  }
}


#Create EIP & NAT Gateway

resource "aws_eip" "bdiplusvpc-nat" {
  domain = "vpc"

  tags = {
    Name = "bdiplus-nat"
  }
}

resource "aws_nat_gateway" "bdiplus-nat" {
  allocation_id = aws_eip.bdiplusvpc-nat.id
  subnet_id     = element(aws_subnet.public.*.id, 1) # Launch in the first public subnet

  tags = {
    Name = "bdiplus-nat"
  }

  depends_on = [aws_internet_gateway.bdiplusvpc-igw]
}

#Create Route Table
# routing table

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.bdiplusvpc.id

  route {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.bdiplus-nat.id
    }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.bdiplusvpc.id

  route {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.bdiplusvpc-igw.id
    }

  tags = {
    Name = "public-rt"
  }
}

#Create Route Table Association
# routing table association

resource "aws_route_table_association" "private-rta" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-rta" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
