terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ¡CLAVE PARA AWS ACADEMY! Obtenemos el rol existente en lugar de crear uno.
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}