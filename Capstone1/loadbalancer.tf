# Create an Elastic Load Balancer (ELB)
resource "aws_lb" "capstone1-jenkins-elb" {
  name               = "capstone1-jenkins-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.capstone1-jenkins-master-elb-sg.id]
  subnets            = [aws_subnet.capstone1-pub-1.id, aws_subnet.capstone1-pub-2.id, aws_subnet.capstone1-pub-3.id]
  depends_on         = [aws_internet_gateway.capstone1-igw]
}

# Create a target group for the Jenkins application servers
resource "aws_lb_target_group" "capstone1-jenkins-elb-tg" {
  name     = "capstone1-jenkins-elb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.capstone1.id

  health_check {
    path                = "/"
    port                = 8080
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }
}

resource "aws_lb_listener" "capstone1-jenkins-elb-lstnr" {
  load_balancer_arn = aws_lb.capstone1-jenkins-elb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.capstone1-jenkins-elb-tg.arn
  }
}
