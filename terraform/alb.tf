# Crear el Application Load Balancer
resource "aws_lb" "main" {
  name               = "task-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets
}

# Crear el Target Group (Apunta al puerto 80 del NGINX)
resource "aws_lb_target_group" "api_gateway" {
  name        = "api-gateway-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip" # Requerido para contenedores Fargate

  health_check {
    path                = "/" # El frontend responderá aquí
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

# Crear el Listener (Escucha en el puerto 80 del ALB y envía al Target Group)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_gateway.arn
  }
}