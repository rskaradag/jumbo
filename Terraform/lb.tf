resource "aws_lb" "lb" {
  name            = "${var.app_name}-lb"
  subnets         = [aws_subnet.public[0].id, aws_subnet.public[1].id]
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "lb_target_group" {
  name        = "${var.app_name}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.jumbo_vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.id
    type             = "forward"
  }
}

resource "aws_security_group" "lb" {
  name   = "${var.app_name}alb-security-group"
  vpc_id = aws_vpc.jumbo_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}