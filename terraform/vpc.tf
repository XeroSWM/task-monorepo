# Usamos el módulo oficial para simplificar la creación de la VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "task-monorepo-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # Uno solo para ahorrar costos en Academy

  enable_dns_hostnames = true
  enable_dns_support   = true
}

# 1. Security Group para el ALB (Expuesto a Internet)
resource "aws_security_group" "alb_sg" {
  name        = "task-alb-sg"
  description = "Permitir trafico HTTP de internet"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Security Group para los Microservicios (ECS)
resource "aws_security_group" "ecs_sg" {
  name        = "task-ecs-sg"
  description = "Permitir trafico interno y desde el ALB"
  vpc_id      = module.vpc.vpc_id

  # Permitir entrada desde el balanceador (al puerto 80 del API Gateway)
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # ¡LA SOLUCIÓN A TU PROBLEMA DE COMUNICACIÓN!
  # Permite que todos los servicios dentro de este SG hablen entre sí libremente
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Security Group para la Base de Datos (RDS)
resource "aws_security_group" "rds_sg" {
  name        = "task-rds-sg"
  description = "Permitir trafico de DB solo desde ECS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}