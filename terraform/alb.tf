resource "aws_lb" "main" {
  name               = "task-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets
}

# 1. Target Groups (Las carpetas destino)
resource "aws_lb_target_group" "frontend" {
  name        = "frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  health_check { path = "/" }
}

resource "aws_lb_target_group" "auth" {
  name        = "auth-tg"
  port        = 3001
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  health_check { path = "/", matcher = "200-499" } # matcher 200-499 evita que falle si devuelve un 404
}

resource "aws_lb_target_group" "core" {
  name        = "core-tg"
  port        = 3002
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  health_check { path = "/", matcher = "200-499" }
}

resource "aws_lb_target_group" "dashboard" {
  name        = "dash-tg"
  port        = 3003
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  health_check { path = "/", matcher = "200-499" }
}

# 2. Listener (El portero del puerto 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# 3. Reglas de Enrutamiento (Tu nuevo NGINX)
resource "aws_lb_listener_rule" "auth_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10
  action { type = "forward", target_group_arn = aws_lb_target_group.auth.arn }
  condition { path_pattern { values = ["/api/auth/*"] } }
}

resource "aws_lb_listener_rule" "core_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20
  action { type = "forward", target_group_arn = aws_lb_target_group.core.arn }
  condition { path_pattern { values = ["/api/core/*"] } }
}

resource "aws_lb_listener_rule" "dashboard_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30
  action { type = "forward", target_group_arn = aws_lb_target_group.dashboard.arn }
  condition { path_pattern { values = ["/api/dashboard/*"] } }
}