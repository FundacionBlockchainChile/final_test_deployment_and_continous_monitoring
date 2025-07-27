# Etapa 1: Build - Instalar dependencias
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias de producción
RUN npm install --only=production

# Etapa 2: Production - Crear la imagen final
FROM node:18-alpine

WORKDIR /usr/src/app

# Copiar las dependencias instaladas desde la etapa de 'builder'
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copiar el código de la aplicación
COPY server.js .

# Exponer el puerto que usa la aplicación
EXPOSE 8080

# Comando para iniciar la aplicación
CMD [ "node", "server.js" ] 