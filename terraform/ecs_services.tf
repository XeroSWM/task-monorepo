# ==========================================
# 1. API GATEWAY (NGINX) - Conectado al ALB
# ==========================================
resource "aws_ecs_task_definition" "api_gateway" {
  family                   = "api-gateway-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.lab_role.arn # Obligatorio en AWS Academy
  task_role_arn            = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([{
    name      = "api-gateway"
    image     = "${var.docker_username}/api-gateway:latest" # Tu imagen de Docker Hub
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

resource "aws_ecs_service" "api_gateway" {
  name            = "api-gateway-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api_gateway.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_gateway.arn
    container_name   = "api-gateway"
    container_port   = 80
  }
}

# ==========================================
# 2. AUTH SERVICE - Comunicación Interna
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

# Configuración de Service Discovery para que NGINX lo encuentre
resource "aws_service_discovery_service" "auth_service" {
  name = "auth-service"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
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

  service_registries {
    registry_arn = aws_service_discovery_service.auth_service.arn
  }
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

resource "aws_service_discovery_service" "core_service" {
  name = "core-service"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
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
  service_registries {
    registry_arn = aws_service_discovery_service.core_service.arn
  }
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

resource "aws_service_discovery_service" "dashboard_service" {
  name = "dashboard-service"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
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
  service_registries {
    registry_arn = aws_service_discovery_service.dashboard_service.arn
  }
}

# ==========================================
# 5. FRONTEND - Puerto 80 (Interno)
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

resource "aws_service_discovery_service" "frontend" {
  name = "frontend"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn = aws_service_discovery_service.frontend.arn
  }
}