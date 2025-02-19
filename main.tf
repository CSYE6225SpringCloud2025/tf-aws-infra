# Create VPCs dynamically
resource "aws_vpc" "vpcs" {
  count      = length(var.vpcs)
  cidr_block = var.vpcs[count.index].cidr_block

  tags = {
    Name = "tf-${var.vpcs[count.index].name}"
  }
}

# Create Public Subnets
resource "aws_subnet" "public_subnets" {
  count             = length(var.vpcs) * var.num_public_subnets
  vpc_id            = aws_vpc.vpcs[floor(count.index / var.num_public_subnets)].id
  cidr_block        = cidrsubnet(var.vpcs[floor(count.index / var.num_public_subnets)].cidr_block, 8, count.index)
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = {
    Name = "tf-public-${var.vpcs[floor(count.index / var.num_public_subnets)].name}-${count.index + 1}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnets" {
  count             = length(var.vpcs) * var.num_private_subnets
  vpc_id            = aws_vpc.vpcs[floor(count.index / var.num_private_subnets)].id
  cidr_block        = cidrsubnet(var.vpcs[floor(count.index / var.num_private_subnets)].cidr_block, 8, count.index + var.num_public_subnets)
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = {
    Name = "tf-private-${var.vpcs[floor(count.index / var.num_private_subnets)].name}-${count.index + 1}"
  }
}

# Create Internet Gateway for each VPC
resource "aws_internet_gateway" "igws" {
  count  = length(var.vpcs)
  vpc_id = aws_vpc.vpcs[count.index].id

  tags = {
    Name = "tf-igw-${var.vpcs[count.index].name}"
  }
}

# Create Public Route Tables
resource "aws_route_table" "public_route_tables" {
  count  = length(var.vpcs)
  vpc_id = aws_vpc.vpcs[count.index].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igws[count.index].id
  }

  tags = {
    Name = "tf-public-rt-${var.vpcs[count.index].name}"
  }
}

# Associate Public Subnets with Public Route Tables
resource "aws_route_table_association" "public_associations" {
  count          = length(var.vpcs) * var.num_public_subnets
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_tables[floor(count.index / var.num_public_subnets)].id
}

# Create Private Route Tables
resource "aws_route_table" "private_route_tables" {
  count  = length(var.vpcs)
  vpc_id = aws_vpc.vpcs[count.index].id

  tags = {
    Name = "tf-private-rt-${var.vpcs[count.index].name}"
  }
}

# Associate Private Subnets with Private Route Tables
resource "aws_route_table_association" "private_associations" {
  count          = length(var.vpcs) * var.num_private_subnets
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[floor(count.index / var.num_private_subnets)].id
}
