resource "aws_eip" "egress_ngw_eip_a" {
  domain = "vpc"
  tags = {
    Name = "${var.prefix}-ngw-eip-a"
  }
}


resource "aws_eip" "egress_ngw_eip_b" {
  domain = "vpc"
  tags = {
    Name = "${var.prefix}-ngw-eip-b"
  }
}

resource "aws_nat_gateway" "egress_ngw_a" {
  allocation_id = aws_eip.egress_ngw_eip_a.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "${var.prefix}-egress-ngw-a"
  }
}

resource "aws_nat_gateway" "egress_ngw_b" {
  allocation_id = aws_eip.egress_ngw_eip_b.id
  subnet_id     = aws_subnet.public_subnet_b.id

  tags = {
    Name = "${var.prefix}-egress-ngw-b"
  }
}