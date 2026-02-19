FROM nginx:alpine

# Sobrescribir la configuración por defecto de NGINX con tu nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]