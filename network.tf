# vpc
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}
# internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# subnets
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "private2"
  }
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "public2"
  }
}
# EIP for nat gateway
resource "aws_eip" "eip1" {
  vpc = true
}

resource "aws_eip" "eip2" {
  vpc = true
}


# nat gateway
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "nat1"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public2.id

  tags = {
    Name = "nat2"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}


# routing table
resource "aws_route_table" "nat1_gateway_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name = "nat gateway 1 route"
  }
}
resource "aws_route_table" "nat2_gateway_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat2.id
  }

  tags = {
    Name = "nat gateway 2 route"
  }
}
resource "aws_route_table" "internet_gateway_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "internet gateway route"
  }
}

# routing table assoiciation
resource "aws_route_table_association" "route_associate_private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.nat1_gateway_route.id
}
resource "aws_route_table_association" "route_associate_private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.nat2_gateway_route.id
}
resource "aws_route_table_association" "route_associate_public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.internet_gateway_route.id
}
resource "aws_route_table_association" "route_associate_public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.internet_gateway_route.id
}