variable "aws_region" {
  description = "Región de AWS para desplegar los recursos."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto, usado para etiquetar recursos."
  type        = string
  default     = "PortTrack"
}

# Variables de Red (VPC)
variable "vpc_cidr" {
  description = "Rango CIDR para la VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para los recursos de red."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "Rangos CIDR para las subredes públicas."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Rangos CIDR para las subredes privadas."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# Variables de Contenedor (ECR & ECS)
variable "ecr_repository_name" {
  description = "Nombre del repositorio ECR para la imagen del servicio."
  type        = string
  default     = "porttrack-barcos-service"
}

variable "container_port" {
  description = "Puerto que expone el contenedor."
  type        = number
  default     = 8080
}

variable "container_cpu" {
  description = "Unidades de CPU a asignar al contenedor."
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memoria (en MiB) a asignar al contenedor."
  type        = number
  default     = 512
}

variable "service_desired_count" {
  description = "Número de instancias deseadas del servicio."
  type        = number
  default     = 1
} 