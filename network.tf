resource "aws_vpc" "metabase_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "Name" = "metabase-vpc"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.metabase_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${local.region}a"

  tags = {
    Name = "metabase-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.metabase_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${local.region}b"

  tags = {
    Name = "metabase-private-subnet-2"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.metabase_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${local.region}a"

  tags = {
    Name = "metabase-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.metabase_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${local.region}b"

  tags = {
    Name = "metabase-public-subnet-2"
  }
}

resource "aws_internet_gateway" "metabase_ig" {
  vpc_id = aws_vpc.metabase_vpc.id

  tags = {
    Name = "metabase-ig"
  }
}

resource "aws_eip" "nat_gateway_ip" {
  vpc = true
}

resource "aws_nat_gateway" "metabase_nat_gateway" {
  allocation_id = aws_eip.nat_gateway_ip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_internet_gateway.metabase_ig]
}

resource "aws_route_table" "metabase_private_rt" {
  vpc_id = aws_vpc.metabase_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.metabase_nat_gateway.id
  }

  tags = {
    Name = "metabase-private-rt"
  }
}

resource "aws_route_table" "metabase_public_rt" {
  vpc_id = aws_vpc.metabase_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.metabase_ig.id
  }

  tags = {
    Name = "metabase-public-rt"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.metabase_public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.metabase_public_rt.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.metabase_private_rt.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.metabase_private_rt.id
}
