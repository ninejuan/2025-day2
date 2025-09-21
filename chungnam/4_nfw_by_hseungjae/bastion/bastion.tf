resource "tls_private_key" "bastin_key" {
  algorithm = "RSA"
  rsa_bits  = 2048

}

resource "aws_key_pair" "bastion_key_pair" {
  key_name   = "ws2025-sn-key"
  public_key = tls_private_key.bastin_key.public_key_openssh
}

resource "local_file" "bastion_private_key" {
  content  = tls_private_key.bastin_key.private_key_pem
  filename = "${path.module}/ws2025-sn-key.pem"
}

/*
resource "null_resource" "bastion_key_permissions" {
  depends_on = [local_file.bastion_private_key]
  
  provisioner "local-exec" {
    command = <<-EOT
      icacls "${path.module}\\bastion-key.pem" /inheritance:r
      icacls "${path.module}\\bastion-key.pem" /grant:r "%USERNAME%":(R,W)
      icacls "${path.module}\\bastion-key.pem" /remove "Everyone"
      icacls "${path.module}\\bastion-key.pem" /remove "Users"
      icacls "${path.module}\\bastion-key.pem" /remove "Authenticated Users"
      icacls "${path.module}\\bastion-key.pem" /remove "SYSTEM"
      icacls "${path.module}\\bastion-key.pem" /remove "Administrators"
    EOT
    interpreter = ["cmd", "/C"]
  }
}*/

resource "aws_instance" "bastion" {
  ami                     = var.ami_id
  instance_type           = "t3.small"
  key_name                = aws_key_pair.bastion_key_pair.key_name
  subnet_id               = var.subnets[0]
  vpc_security_group_ids  = [aws_security_group.bastion_sg.id]
  iam_instance_profile    = aws_iam_instance_profile.bastion_profile.name

  associate_public_ip_address = false

  user_data = base64encode(<<-EOF
EOF
)

  tags = {
    Name = "app-bastion"
  }
}
