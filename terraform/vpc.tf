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

# 2. Security Group para las Instancias EC2
resource "aws_security_group" "ec2_sg" {
  name        = "task-ec2-sg"
  vpc_id      = module.vpc.vpc_id

  # Permitir entrada desde el balanceador a todos los puertos
  ingress {
    from_port       = 80
    to_port         = 3003
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  
  # Opcional: Permitir acceso directo para que veas tus IPs públicas funcionar
  ingress {
    from_port   = 80
    to_port     = 3003
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