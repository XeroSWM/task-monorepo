# ==========================================
# 1. FRONTEND - Puerto 80
# ==========================================
resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.lab_role.arn
  task_role_arn            = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = "${var.docker_username}/frontend:latest"
    essential = true
    portMappings = [{ 
      containerPort = 80
      hostPort      = 80 
    }]
  }])
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 80
  }

  # Obliga a esperar a que el puerto 80 del balanceador exista
  depends_on = [aws_lb_listener.http]
}

# ==========================================
# 2. AUTH SERVICE - Puerto 3001
# ==========================================
resource "aws_ecs_task_definition" "auth_service" {
  family                   = "auth-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.lab_role.arn
  task_role_arn            = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([{
    name      = "auth-service"
    image     = "${var.docker_username}/auth-service:latest"
    essential = true
    portMappings = [{ 
      containerPort = 3001
      hostPort      = 3001 
    }]
    environment = [
      { name = "PORT", value = "3001" },
      { name = "DATABASE_URL", value = "postgresql://taskuser:${var.db_password}@${aws_db_instance.postgres.address}:5432/taskdb" },
      { name = "JWT_SECRET", value = "supersecreto_para_desarrollo" }
    ]
  }])
}

resource "aws_ecs_service" "auth_service" {
  name            = "auth-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.auth_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.auth.arn
    container_name   = "auth-service"
    container_port   = 3001
  }

  # Obliga a esperar a que la regla de enrutamiento /api/auth/* exista
  depends_on = [aws_lb_listener_rule.auth_rule]
}

# ==========================================
# 3. CORE SERVICE - Puerto 3002
# ==========================================
resource "aws_ecs_task_definition" "core_service" {
  family                   = "core-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.lab_role.arn
  task_role_arn            = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([{
    name      = "core-service"
    image     = "${var.docker_username}/core-service:latest"
    essential = true
    portMappings = [{ 
      containerPort = 3002
      hostPort      = 3002 
    }]
    environment = [
      { name = "PORT", value = "3002" },
      { name = "DATABASE_URL", value = "postgresql://taskuser:${var.db_password}@${aws_db_instance.postgres.address}:5432/taskdb" },
      { name = "JWT_SECRET", value = "supersecreto_para_desarrollo" }
    ]
  }])
}

resource "aws_ecs_service" "core_service" {
  name            = "core-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.core_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.core.arn
    container_name   = "core-service"
    container_port   = 3002
  }

  # Obliga a esperar a que la regla de enrutamiento /api/core/* exista
  depends_on = [aws_lb_listener_rule.core_rule]
}

# ==========================================
# 4. DASHBOARD SERVICE - Puerto 3003
# ==========================================
resource "aws_ecs_task_definition" "dashboard_service" {
  family                   = "dashboard-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.lab_role.arn
  task_role_arn            = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([{
    name      = "dashboard-service"
    image     = "${var.docker_username}/dashboard-service:latest"
    essential = true
    portMappings = [{ 
      containerPort = 3003
      hostPort      = 3003 
    }]
    environment = [
      { name = "PORT", value = "3003" },
      { name = "DATABASE_URL", value = "postgresql://taskuser:${var.db_password}@${aws_db_instance.postgres.address}:5432/taskdb" },
      { name = "JWT_SECRET", value = "supersecreto_para_desarrollo" }
    ]
  }])
}

resource "aws_ecs_service" "dashboard_service" {
  name            = "dashboard-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.dashboard_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.dashboard.arn
    container_name   = "dashboard-service"
    container_port   = 3003
  }

  # Obliga a esperar a que la regla de enrutamiento /api/dashboard/* exista
  depends_on = [aws_lb_listener_rule.dashboard_rule]
}