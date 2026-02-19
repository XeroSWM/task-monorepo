# 1. Security Group para la Base de Datos (RDS)
resource "aws_security_group" "rds_sg" {
  name        = "task-rds-sg"
  description = "Permitir trafico de DB solo desde las instancias EC2"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    # ¡EL CAMBIO CLAVE! Ahora permite conexión desde las EC2 puras
    security_groups = [aws_security_group.ec2_sg.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Grupo de Subredes (Ubicamos la BD en las redes privadas por seguridad)
resource "aws_db_subnet_group" "main" {
  name       = "task-db-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

# 3. La Instancia de PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier             = "task-db"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "taskuser"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  # Fundamental para AWS Academy: permite destruir la BD sin pedir respaldos
  skip_final_snapshot    = true 
  
  publicly_accessible    = false
  db_name                = "taskdb"
}