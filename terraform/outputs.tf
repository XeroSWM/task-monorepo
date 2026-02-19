output "url_sistema_alb" { 
  value       = "http://${aws_lb.main.dns_name}" 
  description = "COPIA ESTA URL EN TU NAVEGADOR PARA VER EL SISTEMA"
}

output "ip_frontend" { 
  value = aws_instance.frontend.public_ip 
}

output "ip_auth" { 
  value = aws_instance.auth.public_ip 
}

output "ip_core" { 
  value = aws_instance.core.public_ip 
}

output "ip_dashboard" { 
  value = aws_instance.dashboard.public_ip 
}