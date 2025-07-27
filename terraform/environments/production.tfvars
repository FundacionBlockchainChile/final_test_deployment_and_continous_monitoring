# Production Environment Configuration
# Usamos valores más grandes para manejar una carga de trabajo mayor.

service_desired_count = 3       # Mayor número de réplicas para alta disponibilidad
container_cpu         = 512     # 0.5 vCPU
container_memory      = 1024    # 1 GB 