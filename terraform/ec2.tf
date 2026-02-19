data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# ================= FRONTEND =================
resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              yum update -y && yum install -y docker && service docker start
              docker run -d -p 80:80 ${var.docker_username}/frontend:latest
              EOF
  tags = { Name = "1-Frontend-EC2" }
}
resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.frontend.id
  port             = 80
}

# ================= AUTH SERVICE =================
resource "aws_instance" "auth" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[1]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              yum update -y && yum install -y docker && service docker start
              docker run -d -p 3001:3001 -e PORT=3001 -e DATABASE_URL="postgresql://taskuser:${var.db_password}@${aws_db_instance.postgres.address}:5432/taskdb" -e JWT_SECRET="supersecreto_para_desarrollo" ${var.docker_username}/auth-service:latest
              EOF
  tags = { Name = "2-Auth-EC2" }
}
resource "aws_lb_target_group_attachment" "auth" {
  target_group_arn = aws_lb_target_group.auth.arn
  target_id        = aws_instance.auth.id
  port             = 3001
}

# ================= CORE SERVICE =================
resource "aws_instance" "core" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              yum update -y && yum install -y docker && service docker start
              docker run -d -p 3002:3002 -e PORT=3002 -e DATABASE_URL="postgresql://taskuser:${var.db_password}@${aws_db_instance.postgres.address}:5432/taskdb" -e JWT_SECRET="supersecreto_para_desarrollo" ${var.docker_username}/core-service:latest
              EOF
  tags = { Name = "3-Core-EC2" }
}
resource "aws_lb_target_group_attachment" "core" {
  target_group_arn = aws_lb_target_group.core.arn
  target_id        = aws_instance.core.id
  port             = 3002
}

# ================= DASHBOARD SERVICE =================
resource "aws_instance" "dashboard" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[1]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              yum update -y && yum install -y docker && service docker start
              docker run -d -p 3003:3003 -e PORT=3003 -e DATABASE_URL="postgresql://taskuser:${var.db_password}@${aws_db_instance.postgres.address}:5432/taskdb" -e JWT_SECRET="supersecreto_para_desarrollo" ${var.docker_username}/dashboard-service:latest
              EOF
  tags = { Name = "4-Dashboard-EC2" }
}
resource "aws_lb_target_group_attachment" "dashboard" {
  target_group_arn = aws_lb_target_group.dashboard.arn
  target_id        = aws_instance.dashboard.id
  port             = 3003
}