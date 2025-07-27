terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  // Backend S3 para almacenar el estado de Terraform de forma remota
  // Se deja comentado para evitar errores en ejecuciones locales sin configuración.
  /*
  backend "s3" {
    bucket         = "porttrack-terraform-state-bucket"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_locks"
    encrypt        = true
  }
  */
}

provider "aws" {
  region = var.aws_region
}

# Creación de la VPC y recursos de red
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  availability_zones = var.availability_zones
}

# Creación del repositorio de imágenes
module "ecr" {
  source = "./modules/ecr"

  ecr_repository_name = var.ecr_repository_name
}

# Creación del servicio en ECS Fargate y el balanceador de carga
module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  
  ecr_repository_url = module.ecr.repository_url
  
  container_port = var.container_port
  container_cpu = var.container_cpu
  container_memory = var.container_memory
  service_desired_count = var.service_desired_count
} 