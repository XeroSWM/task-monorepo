variable "aws_region" {
  default = "us-east-1"
}

variable "db_password" {
  description = "Contraseña para PostgreSQL"
  type        = string
  sensitive   = true
}

variable "docker_username" {
  description = "Tu usuario de Docker Hub (ej: xmonteros)"
  type        = string
}