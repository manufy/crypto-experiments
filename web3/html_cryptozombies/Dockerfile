# Usar una imagen base oficial de Go para construir el binario
FROM golang:1.19-alpine AS build

# Crear un directorio de trabajo
WORKDIR /app

# Copiar el go.mod y go.sum y descargar las dependencias
COPY go.mod go.sum ./
RUN go mod download

# Copiar el código fuente de la aplicación
COPY . .

# Compilar el binario
RUN go build -o go-app

# Crear una etapa final mínima
FROM alpine:latest

# Instalar certificados SSL
RUN apk --no-cache add ca-certificates

# Crear un directorio para la aplicación
WORKDIR /root/

# Copiar el binario compilado desde la etapa de construcción
COPY --from=build /app/go-app .

# Copiar la carpeta public al contenedor
COPY public ./public

# Exponer el puerto en el que se ejecutará la aplicación
EXPOSE 3000

# Comando para ejecutar la aplicación
CMD ["./go-app"]

