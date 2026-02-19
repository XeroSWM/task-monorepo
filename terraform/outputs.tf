output "url_sistema_alb" { 
  value       = "http://${aws_lb.main.dns_name}" 
  description = "COPIA ESTA URL EN TU NAVEGADOR PARA VER EL SISTEMA"
}

output "ip_frontend" { 
  value = aws_eip.frontend_eip.public_ip 
}

output "ip_auth" { 
  value = aws_eip.auth_eip.public_ip 
}

output "ip_core" { 
  value = aws_eip.core_eip.public_ip 
}

output "ip_dashboard" { 
  value = aws_eip.dashboard_eip.public_ip 
}