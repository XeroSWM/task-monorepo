resource "aws_ecs_cluster" "main" {
  name = "task-monorepo-cluster"
}

# Service Discovery (Cloud Map) para la comunicación interna por DNS
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "local"
  description = "DNS interno para microservicios"
  vpc         = module.vpc.vpc_id
}