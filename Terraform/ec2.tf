resource "aws_instance" "master" {
  ami                         = "ami-0caef02b518350c8b"
  instance_type               = "t2.micro"
  associate_public_ip_address = true

  key_name = aws_key_pair.master.key_name

  security_groups = ["${aws_security_group.master.id}"]
  subnet_id       = aws_subnet.public[0].id

  user_data = <<EOF
#!/bin/bash
sudo apt install amazon-efs-utils -y
echo "Mount NFS"
sudo mount -t efs -o tls ${aws_efs_access_point.app.id}:/ /mnt/efs
EOF

  tags = {
    Name = "master"
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "private_key" {
  filename          = "jumbo_key.pem"
  sensitive_content = tls_private_key.key.private_key_pem
  file_permission   = "0404"
}
resource "aws_key_pair" "master" {
  key_name   = "jumbo_key"
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_security_group" "master" {
  name        = "${var.app_name}-master"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.jumbo_vpc.id

  ingress {
    protocol    = "6"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "6"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "6"
    from_port   = 2049
    to_port     = 2049
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}