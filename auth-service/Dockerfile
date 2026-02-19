FROM node:18-alpine

WORKDIR /app

# Copiar solo los archivos de dependencias primero (optimiza la caché de Docker)
COPY package*.json ./

# Instalar dependencias (solo las de producción)
RUN npm install --omit=dev

# Copiar el resto del código (el index.js)
COPY . .

# Exponer el puerto del servicio
EXPOSE 3001

# Comando para iniciar
CMD ["node", "index.js"]