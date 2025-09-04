resource "aws_instance" "instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile_name

  user_data = base64encode(templatefile(var.user_data_template, var.user_data_vars))

  tags = merge(var.tags, {
    Name = var.instance_name
  })
}

resource "aws_eip" "eip" {
  count  = var.create_eip ? 1 : 0
  instance = aws_instance.instance.id
  domain   = "vpc"
}
