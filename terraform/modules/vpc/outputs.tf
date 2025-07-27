output "vpc_id" {
  description = "El ID de la VPC creada."
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "Lista de IDs de las subredes públicas."
  value       = aws_subnet.public.*.id
}

output "private_subnets" {
  description = "Lista de IDs de las subredes privadas."
  value       = aws_subnet.private.*.id
} 