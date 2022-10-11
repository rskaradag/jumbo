resource "aws_instance" "master" {
  ami                         = "ami-0caef02b518350c8b"
  instance_type               = "t2.micro"
  associate_public_ip_address = true

  key_name = aws_key_pair.master.key_name

  security_groups = ["${aws_security_group.master.id}"]
  subnet_id       = aws_subnet.public[0].id

  user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get -y install git binutils
git clone https://github.com/aws/efs-utils
cd efs-utils
./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb
pip3 install botocore
sudo mount -t efs -o tls ${aws_efs_access_point.app.id}:/ /mnt
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
sudo wget -q -O /usr/share/keyrings/grafana.key https://packages.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install grafana -y
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server
EOF

  tags = {
    Name = "master"
  }
}

data "aws_iam_policy_document" "EC2EFSPolicyDoc" {
  statement {
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "ec2_role" {
  assume_role_policy = data.aws_iam_policy_document.EC2TrustPolicy.json
  name               = "${var.app_name}-ec2-iam-role"

  inline_policy {
    name   = "efs-policy"
    policy = data.aws_iam_policy_document.EC2EFSPolicyDoc.json
  }
}

data "aws_iam_policy_document" "EC2TrustPolicy" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
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