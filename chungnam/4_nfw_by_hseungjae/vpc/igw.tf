resource "aws_internet_gateway" "egress_igw" {
  vpc_id = module.egress_vpc.vpc_id

  tags = {
    Name = "${var.prefix}-igw"
  }
}