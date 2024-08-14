# Load Balancer
resource "aws_lb" "terraform-lab" {
  name               = "${var.ec2_instance_name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.load-balancer.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
}

# Target group
resource "aws_alb_target_group" "default-target-group" {
  name     = "${var.ec2_instance_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.terraform-lab-vpc.id

  health_check {
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 60
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "ec2_attachment" {
  target_group_arn = aws_alb_target_group.default-target-group.arn
  target_id        = aws_instance.ec2.id
  port             = 80
}

resource "aws_alb_listener" "ec2-alb-http-listener" {
  load_balancer_arn = aws_lb.terraform-lab.id
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.default-target-group]

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.default-target-group.arn
  }
}
