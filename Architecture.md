```mermaid
graph TD
    subgraph "Desarrollo y Repositorio"
        Dev("Desarrollador") -- "git push" --> Repo("💻 GitHub Repo");
    end

    subgraph "Pipeline CI/CD (GitHub Actions)"
        Repo -- "Activa" --> CI_CD;
        CI_CD -- "1. Test & Scan" --> Test["Lint, Unit Tests, Trivy Scan"];
        Test -- "2. Build & Push" --> Build["Docker Build & Push"];
        Build -- "Push to" --> ECR("📦 AWS ECR");
        Build -- "3. Plan de Infraestructura" --> Plan["Terraform Plan"];
        Plan -- "4. Aprobación Manual" --> ManualApproval{{"Revisión y Aprobación"}};
        ManualApproval -- "5. Despliegue (Teórico)" --> Deploy["Terraform Apply"];
    end

    subgraph "Infraestructura AWS (Definida en Terraform)"
        Deploy -- "Provisiona/Actualiza" --> VPC;
        ECR -- "Imagen Docker" --> ECS;
        
        subgraph "VPC (Virtual Private Cloud)"
            ALB("🌐 Application Load Balancer") --> ECS;
            ECS("🚀 ECS Fargate (Servicio Node.js)");
            ECS --> RDS("🗃️ RDS (Base de Datos)");
        end
    end

    subgraph "Usuarios Finales"
        User("Usuario") --> ALB;
    end

    subgraph "Monitoreo y Observabilidad (Stack Local de Demostración)"
        M_ECS("Servicio Node.js") -- "Genera Métricas" --> Prometheus;
        M_ECS -- "Genera Logs" --> Filebeat;
        
        Filebeat -- "Envía Logs" --> Logstash;
        Logstash -- "Procesa" --> Elasticsearch;
        Elasticsearch -- "Almacena" --> Kibana("Kibana - Visualización de Logs");
        
        Prometheus("Prometheus - Recolección de Métricas") -- "Envía Alertas" --> Alertmanager;
        Prometheus -- "Fuente de Datos" --> Grafana("Grafana - Dashboards de Métricas");
    end

    subgraph "Automatización y Notificaciones (ChatOps)"
        Alertmanager -- "Notifica Alertas Críticas" --> Slack;
        CI_CD -- "Notifica Estado del Pipeline" --> Slack;
        DevOps("Equipo DevOps") -- "Ejecuta comandos" --> Hubot;
        Hubot -- "Interactúa con" --> Slack("💬 Slack");
        Hubot -- "Dispara Pipeline" --> CI_CD;
    end

    style Dev fill:#c9daf8
    style User fill:#c9daf8
    style DevOps fill:#c9daf8
    style Slack fill:#f4cccc
end 