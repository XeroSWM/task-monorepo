output "1_URL_SISTEMA_ALB" { 
  value = "http://${aws_lb.main.dns_name}" 
}
output "2_Frontend_IP"  { value = aws_instance.frontend.public_ip }
output "3_Auth_IP"      { value = aws_instance.auth.public_ip }
output "4_Core_IP"      { value = aws_instance.core.public_ip }
output "5_Dashboard_IP" { value = aws_instance.dashboard.public_ip }