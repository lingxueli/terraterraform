resource "aws_lb" "front_end" {
  name               = "lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "front_end" {
  name        = "lb-tg"
  port        = 80
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_lb_target_group_attachment" "front_end1" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "front_end2" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_instance.web2.id
  port             = 80
}