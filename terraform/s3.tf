# 1. Generador de sufijo aleatorio para que el nombre sea único a nivel mundial
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 2. El Bucket S3 principal
resource "aws_s3_bucket" "app_storage" {
  bucket        = "task-monorepo-storage-${random_id.bucket_suffix.hex}"
  
  # Fundamental en AWS Academy: permite destruir el bucket aunque tenga archivos dentro
  force_destroy = true 

  tags = {
    Name = "Sistema-Archivos-S3"
  }
}

# 3. Configuración CORS (Para que tu Frontend en React pueda subir/leer archivos)
resource "aws_s3_bucket_cors_configuration" "app_storage_cors" {
  bucket = aws_s3_bucket.app_storage.id

 cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    # Terraform pondrá tu link de AWS automáticamente aquí:
    allowed_origins = ["http://${aws_lb.main.dns_name}"] 
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}