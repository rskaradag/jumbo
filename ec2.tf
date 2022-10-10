
resource "aws_instance" "master" {
  ami           = "ami-0caef02b518350c8b"
  instance_type = "t2.micro"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.eth0.id
  }
  tags = {
    Name = "master"
  }
}



resource "aws_network_interface" "eth0" {
  subnet_id       = aws_subnet.public[0].id
  private_ips     = ["10.10.1.109"]
  security_groups = [aws_security_group.master_sg.id]
}

resource "aws_security_group" "master_sg" {
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