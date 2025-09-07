resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

# Internet Gateway (only for Egress VPC)
resource "aws_internet_gateway" "this" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_names[count.index]
  }
}

# Peering Subnets (only for Egress VPC)
resource "aws_subnet" "peering" {
  count             = length(var.peering_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.peering_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = var.peering_subnet_names[count.index]
  }
}

# Firewall Subnets (only for Egress VPC)
resource "aws_subnet" "firewall" {
  count             = length(var.firewall_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.firewall_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = var.firewall_subnet_names[count.index]
  }
}

# Private Subnets (only for App VPC)
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = var.private_subnet_names[count.index]
  }
}

# NAT Gateways (only for Egress VPC)
resource "aws_eip" "nat" {
  count  = var.create_nat_gw ? length(var.public_subnets) : 0
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count         = var.create_nat_gw ? length(var.public_subnets) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.vpc_name}-nat-gw-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.this]
}

# Route Tables - Public
resource "aws_route_table" "public" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.create_igw ? length(aws_subnet.public) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Route Tables - Peering (for Egress VPC)
resource "aws_route_table" "peering" {
  count  = length(var.peering_subnets) > 0 ? length(var.peering_subnets) : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-peering-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "peering" {
  count          = length(aws_subnet.peering)
  subnet_id      = aws_subnet.peering[count.index].id
  route_table_id = aws_route_table.peering[count.index].id
}

# Route Tables - Firewall (for Egress VPC)
resource "aws_route_table" "firewall" {
  count  = length(var.firewall_subnets) > 0 ? length(var.firewall_subnets) : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-firewall-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "firewall" {
  count          = length(aws_subnet.firewall)
  subnet_id      = aws_subnet.firewall[count.index].id
  route_table_id = aws_route_table.firewall[count.index].id
}

# Route Tables - Private (for App VPC)
resource "aws_route_table" "private" {
  count  = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
