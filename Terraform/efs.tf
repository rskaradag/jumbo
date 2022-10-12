resource "aws_efs_file_system" "jumbo_efs" {
  creation_token = var.app_name

  tags = {
    Name = "${var.app_name}-efs"
  }
}

resource "aws_efs_access_point" "app" {
  file_system_id = aws_efs_file_system.jumbo_efs.id
  root_directory {
    path = "/efs/app"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "777"
    }

  }
  posix_user {
    gid = 1000
    uid = 1000
  }
  tags = {
    Name = "${var.app_name}-app-access-point"
  }
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.jumbo_efs.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "Policy01",
    "Statement": [
        {
            "Sid": "Statement",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.jumbo_efs.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientWrite"
            ]
        }
    ]
}
POLICY
}

resource "aws_efs_mount_target" "jumbo_mount" {
  count           = length(aws_subnet.private.*.id)
  file_system_id  = aws_efs_file_system.jumbo_efs.id
  subnet_id       = element(aws_subnet.private.*.id, count.index)
  security_groups = [aws_security_group.efs-sg.id]
}