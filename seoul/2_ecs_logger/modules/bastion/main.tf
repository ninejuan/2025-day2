data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.project_name}-bastion-key"
  public_key = file("${path.module}/../../bastion-key.pub")

  tags = merge(var.tags, {
    Name = "${var.project_name}-bastion-key"
  })
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.bastion.key_name
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id
  user_data              = base64encode(var.user_data)

  tags = merge(var.tags, {
    Name = "${var.project_name}-bastion"
  })
}
