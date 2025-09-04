resource "aws_vpc" "wsi_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "wsi_igw" {
  vpc_id = aws_vpc.wsi_vpc.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_subnet" "wsi_pub_sn_a" {
  vpc_id                  = aws_vpc.wsi_vpc.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-pub-sn-a"
    Type = "public"
  })
}

resource "aws_subnet" "wsi_pub_sn_c" {
  vpc_id                  = aws_vpc.wsi_vpc.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-pub-sn-c"
    Type = "public"
  })
}

resource "aws_subnet" "wsi_priv_sn_a" {
  vpc_id            = aws_vpc.wsi_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = var.availability_zones[0]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-priv-sn-a"
    Type = "private"
  })
}

resource "aws_subnet" "wsi_priv_sn_c" {
  vpc_id            = aws_vpc.wsi_vpc.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = var.availability_zones[1]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-priv-sn-c"
    Type = "private"
  })
}

resource "aws_eip" "wsi_nat_eip_a" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.wsi_igw]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-eip-a"
  })
}

resource "aws_eip" "wsi_nat_eip_c" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.wsi_igw]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-eip-c"
  })
}

resource "aws_nat_gateway" "wsi_nat_a" {
  allocation_id = aws_eip.wsi_nat_eip_a.id
  subnet_id     = aws_subnet.wsi_pub_sn_a.id
  depends_on    = [aws_internet_gateway.wsi_igw]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-a"
  })
}

resource "aws_nat_gateway" "wsi_nat_c" {
  allocation_id = aws_eip.wsi_nat_eip_c.id
  subnet_id     = aws_subnet.wsi_pub_sn_c.id
  depends_on    = [aws_internet_gateway.wsi_igw]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-c"
  })
}

resource "aws_route_table" "wsi_pub_rt" {
  vpc_id = aws_vpc.wsi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wsi_igw.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-pub-rt"
  })
}

resource "aws_route_table" "wsi_priv_rt_a" {
  vpc_id = aws_vpc.wsi_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wsi_nat_a.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-priv-rt-a"
  })
}

resource "aws_route_table" "wsi_priv_rt_c" {
  vpc_id = aws_vpc.wsi_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wsi_nat_c.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-priv-rt-c"
  })
}

resource "aws_route_table_association" "wsi_pub_sn_a_assoc" {
  subnet_id      = aws_subnet.wsi_pub_sn_a.id
  route_table_id = aws_route_table.wsi_pub_rt.id
}

resource "aws_route_table_association" "wsi_pub_sn_c_assoc" {
  subnet_id      = aws_subnet.wsi_pub_sn_c.id
  route_table_id = aws_route_table.wsi_pub_rt.id
}

resource "aws_route_table_association" "wsi_priv_sn_a_assoc" {
  subnet_id      = aws_subnet.wsi_priv_sn_a.id
  route_table_id = aws_route_table.wsi_priv_rt_a.id
}

resource "aws_route_table_association" "wsi_priv_sn_c_assoc" {
  subnet_id      = aws_subnet.wsi_priv_sn_c.id
  route_table_id = aws_route_table.wsi_priv_rt_c.id
}
