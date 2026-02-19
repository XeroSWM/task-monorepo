# Etapa 1: Construcción (Builder)
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
# Vite empaqueta todo el código estático en la carpeta 'dist'
RUN npm run build 

# Etapa 2: Producción (Servidor Web)
FROM nginx:alpine

# Copiamos los archivos compilados del builder a la carpeta pública de NGINX
COPY --from=builder /app/dist /usr/share/nginx/html

# Exponer el puerto interno del contenedor
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]