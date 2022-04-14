resource "aws_lb" "metabase_load_balancer" {
  name               = "metabase-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_security_group.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

resource "aws_lb_target_group" "metabase_target_group" {
  name        = "metabase-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.metabase_vpc.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.metabase_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metabase_target_group.arn
  }
}
