# Evaluación Módulo 7: Despliegue y Monitoreo Continuo para una Plataforma de Navegación Portuaria

Este repositorio contiene la solución propuesta para la evaluación final del módulo "Despliegue y Monitoreo Continuo". El objetivo es diseñar una estrategia completa de CI/CD, IaC, monitoreo y ChatOps para la plataforma ficticia "PortTrack".

**Nota Importante:** Siguiendo los requisitos, este proyecto es una **implementación teórica**. Se han creado todos los artefactos de código, configuración y pipelines, pero no se han desplegado los recursos en la nube.

## 📝 Informe Técnico y Justificación de Decisiones

### 1. Estrategia de Despliegue Continuo (1.5 Puntos)

#### 1.1. Selección del Tipo de Despliegue: Blue-Green

Para una plataforma crítica como PortTrack, donde el tiempo de inactividad puede afectar operaciones portuarias, se ha seleccionado una estrategia de despliegue **Blue-Green**.

* **Justificación:**
  * **Cero Downtime:** Permite desplegar una nueva versión (Green) junto a la versión estable (Blue) sin afectar el tráfico de producción. La transición se realiza de manera instantánea cambiando la ruta del balanceador de carga.
  * **Rollback Inmediato:** En caso de fallo en la nueva versión, el rollback es tan simple como revertir el cambio en el balanceador de carga para que apunte nuevamente al entorno Blue, minimizando el impacto.
  * **Pruebas en un Entorno Idéntico al de Producción:** El entorno Green puede ser sometido a pruebas de humo y validación finales antes de recibir tráfico real, asegurando su estabilidad.

#### 1.2. Justificación de Herramientas CI/CD: GitHub Actions

Se ha elegido **GitHub Actions** como el motor de CI/CD.

* **Justificación:**
  * **Integración Nativa:** Al estar integrado directamente en GitHub, elimina la necesidad de herramientas externas y simplifica la configuración.
  * **Ecosistema Robusto:** Cuenta con un marketplace de acciones reutilizables (ej. `actions/checkout`, `aws-actions/configure-aws-credentials`, `hashicorp/setup-terraform`) que acelera el desarrollo del pipeline.
  * **Gestión de Secretos:** Proporciona un sistema seguro y fácil de usar para gestionar credenciales y secretos a nivel de repositorio y entorno.
  * **Entornos de Despliegue:** Permite definir entornos protegidos (ej. "production") que pueden requerir aprobaciones manuales antes de un despliegue, lo cual es una práctica de seguridad fundamental.

#### 1.3. Estrategias de Rollback y Recuperación

* **Rollback de Aplicación:** Como se mencionó, la estrategia Blue-Green es la principal herramienta de rollback. Si la versión Green falla, el balanceador de carga se redirige inmediatamente a la versión Blue.
* **Rollback de Infraestructura:** Al usar Terraform, cada cambio es declarativo. Si un cambio en la infraestructura (ej. una nueva política de seguridad) causa problemas, se puede revertir fácilmente a través de Git. El commit anterior que contiene el estado funcional de la infraestructura puede ser desplegado nuevamente a través del pipeline.

---

### 2. Configuración de Entornos y Seguridad (1.5 Puntos)

#### 2.1. Diferenciación de Entornos (DEV, STAGING, TEST, PRD)

* **DEV:** Entorno local de los desarrolladores (ej. ejecución del servicio Node.js y el stack de monitoreo con Docker Compose).
* **STAGING:** Un entorno en AWS idéntico a producción pero con menos recursos. Se utiliza para las pruebas de integración finales antes del despliegue en producción. Nuestro pipeline lo gestiona con el archivo `environments/staging.tfvars`.
* **PRD (Producción):** El entorno final donde operan los usuarios. Es gestionado por `environments/production.tfvars` y está protegido por una regla de aprobación manual en GitHub Actions.

#### 2.2. Gestión de Credenciales y Secretos

La gestión de secretos se realiza utilizando **GitHub Encrypted Secrets**.

* **Implementación:** Las credenciales de AWS (`AWS_ACCESS_KEY_ID` y `AWS_SECRET_ACCESS_KEY`) se almacenan como secretos en la configuración del repositorio de GitHub. Los workflows `ci.yml` y `cd.yml` acceden a ellos de forma segura usando la sintaxis `${{ secrets.NOMBRE_DEL_SECRETO }}`.
* **Ventajas:** Las credenciales nunca se exponen en el código, logs o artefactos del pipeline, cumpliendo con las mejores prácticas de seguridad.

#### 2.3. Consideraciones de Seguridad en el Pipeline

* **Escaneo de Vulnerabilidades:** El workflow `ci.yml` incluye un paso que utiliza **Trivy** para escanear la imagen Docker en busca de vulnerabilidades conocidas (CVEs) en el sistema operativo y las librerías. El pipeline está configurado para fallar si se encuentran vulnerabilidades de severidad `HIGH` o `CRITICAL`.
* **Aprobación Manual:** El despliegue al entorno de producción en el workflow `cd.yml` está protegido y requiere la aprobación manual de un revisor, evitando despliegues accidentales.
* **Mínimo Privilegio:** Las credenciales de AWS almacenadas en los secretos deberían, en un escenario real, corresponder a un usuario IAM con los permisos mínimos necesarios para ejecutar las acciones del pipeline (ej. acceso a ECR, ECS y Terraform), en lugar de un usuario con permisos de administrador.

---

### 3. Implementación de Monitoreo Continuo (1.5 Puntos)

Se ha implementado un stack de monitoreo y observabilidad completo, demostrable localmente a través de Docker Compose.

#### 3.1. Selección de Herramientas

* **Métricas (Prometheus y Grafana):** Prometheus es el estándar de facto en el mundo de Kubernetes y contenedores para la recolección de métricas de series temporales. Grafana es la herramienta líder para la visualización de estas métricas en dashboards interactivos.
* **Logs (Stack ELK + Filebeat):** Elasticsearch, Logstash y Kibana forman un stack robusto y escalable para la ingesta, procesamiento y visualización de logs. Filebeat es un agente ligero que se encarga de recolectar los logs de los contenedores y enviarlos a Logstash.

#### 3.2. Estrategia de Manejo de Logs y Métricas

* **Métricas:** La aplicación Node.js expone un endpoint `/metrics` utilizando la librería `prom-client`. Prometheus está configurado para "scrapear" este endpoint periódicamente, almacenando métricas de la aplicación (ej. `http_requests_total`) y del sistema (métricas por defecto como uso de CPU/memoria).
* **Logs:** La aplicación escribe sus logs a la salida estándar (`stdout`). Filebeat, configurado con el input `container`, captura estos logs de todos los contenedores Docker en el host y los enriquece con metadatos del contenedor (nombre, ID, etc.). Luego, los envía a Logstash. Logstash procesa y estructura estos logs, enviándolos finalmente a Elasticsearch para su indexación y almacenamiento.

#### 3.3. Configuración de Alertas y Dashboards

* **Dashboards:** Se ha creado un dashboard pre-configurado para Grafana (`monitoring/grafana/provisioning/dashboards/main.json`) que se provisiona automáticamente al levantar el stack. Este dashboard muestra gráficos clave como "Peticiones HTTP por Segundo" y "Uso de CPU".
* **Alertas:** Aunque no se ha configurado Alertmanager en este proyecto, la estrategia sería definir reglas de alerta en Prometheus (en un archivo `alert.rules.yml`). Estas reglas definirían umbrales críticos (ej. latencia > 500ms, tasa de errores HTTP 5xx > 2%). Cuando una alerta se dispara, Prometheus la enviaría a Alertmanager, que se encargaría de agrupar, desduplicar y enrutar la notificación al canal apropiado (ej. Slack).

---

### 4. Automatización y ChatOps (1.5 Puntos)

La integración de ChatOps permite al equipo de DevOps interactuar con el sistema de CI/CD y monitoreo directamente desde una plataforma de chat como Slack, mejorando la colaboración y la velocidad de respuesta.

* **Herramientas:** Se utilizaría **Hubot** con el adaptador de Slack.
* **Flujos de Trabajo de ChatOps:**
  1. **Despliegue bajo demanda:**
     * **Comando:** `@PortTrack-Bot deploy barcos-service to staging`
     * **Acción:** El bot llamaría a la API de GitHub para disparar el workflow `cd.yml` con los parámetros `service=barcos-service` y `environment=staging`.
  2. **Notificaciones del Pipeline:**
     * **Acción:** Los workflows de GitHub Actions se configurarían para enviar notificaciones a un canal de Slack (`#despliegues`) al inicio, éxito o fallo de un pipeline, proporcionando visibilidad inmediata al equipo.
  3. **Gestión de Incidentes con Alertas:**
     * **Acción:** Alertmanager se configuraría con un webhook para enviar las alertas críticas a un canal de Slack (`#alertas-produccion`).
     * **Ejemplo:** Una alerta de "Alta Latencia en API de Barcos" aparecería en el canal, permitiendo al equipo iniciar inmediatamente la investigación del incidente.

---

## 🚀 Guía de Uso y Demostración Local

### Prerrequisitos

* Docker
* Docker Compose

### Pasos para la Demostración

1. **Clonar el repositorio:**

   ```bash
   git clone <URL_DEL_REPOSITORIO>
   cd <NOMBRE_DEL_DIRECTORIO>
   ```
2. **Levantar el stack de monitoreo:**
   Desde el directorio raíz del proyecto, ejecuta:

   ```bash
   docker-compose -f ./monitoring/docker-compose.yml up --build -d
   ```

   Este comando construirá la imagen de la aplicación y levantará todos los servicios de monitoreo.
3. **Acceder a los servicios:**

   * **Servicio de Barcos:** [http://localhost:8080/api/barcos](http://localhost:8080/api/barcos)
   * **Métricas de Prometheus:** [http://localhost:8080/metrics](http://localhost:8080/metrics)
   * **Prometheus UI:** [http://localhost:9090](http://localhost:9090)
   * **Grafana:** [http://localhost:3000](http://localhost:3000) (user: admin, pass: admin)
   * **Kibana:** [http://localhost:5601](http://localhost:5601)
4. **Generar tráfico:**
   Para ver las métricas en Grafana, puedes generar algo de tráfico al servicio:

   ```bash
   # Puedes usar 'watch' o un bucle para ejecutarlo repetidamente
   curl http://localhost:8080/api/barcos
   ```
5. **Detener el stack:**

   ```bash
   docker-compose -f ./monitoring/docker-compose.yml down
   ```

---

## 🏛️ Diagrama de Arquitectura

```mermaid
graph TD
    %% --- Section: Development & CI/CD ---
    Dev["Desarrollador"] -- "git push" --> Repo["GitHub Repo"];
    Repo -- "Activa" --> Pipeline_Test["1. Test & Scan"];
    Pipeline_Test -- "->" --> Pipeline_Build["2. Build & Push to ECR"];
    Pipeline_Build -- "->" --> Pipeline_Plan["3. Terraform Plan"];
    Pipeline_Plan -- "->" --> Pipeline_Approval{{"4. Aprobación Manual"}};
    Pipeline_Approval -- "->" --> Pipeline_Deploy["5. Despliegue (Teórico)"];
    
    %% --- Section: AWS Infrastructure ---
    ECR["AWS ECR"];
    Pipeline_Build -- "Push to" --> ECR;
    ALB["Application Load Balancer"];
    ECS["ECS Fargate (Servicio Node.js)"];
    RDS["RDS (Base de Datos)"];
    Pipeline_Deploy -- "Provisiona/Actualiza" --> ALB;
    Pipeline_Deploy -- "Provisiona/Actualiza" --> ECS;
    Pipeline_Deploy -- "Provisiona/Actualiza" --> RDS;
    ALB -- "Routes traffic to" --> ECS;
    ECS -- "Pulls image from" --> ECR;
    ECS -- "Connects to" --> RDS;

    %% --- Section: Users ---
    User["Usuario Final"] -- "Accede vía" --> ALB;
    
    %% --- Section: Monitoring & Observability ---
    Prometheus["Prometheus"];
    Grafana["Grafana"];
    Alertmanager["Alertmanager"];
    Filebeat["Filebeat"];
    Logstash["Logstash"];
    Elasticsearch["Elasticsearch"];
    Kibana["Kibana"];
    
    ECS -- "Expone Métricas" --> Prometheus;
    Prometheus -- "Fuente de Datos" --> Grafana;
    Prometheus -- "Envía Alertas" --> Alertmanager;
    
    ECS -- "Genera Logs" --> Filebeat;
    Filebeat -- "Envía a" --> Logstash;
    Logstash -- "Procesa y Envía a" --> Elasticsearch;
    Elasticsearch -- "Almacena para" --> Kibana;

    %% --- Section: ChatOps ---
    Slack["Slack"];
    Hubot["Hubot"];
    DevOps["Equipo DevOps"];
    
    Alertmanager -- "Notifica a" --> Slack;
    Pipeline_Deploy -- "Notifica a" --> Slack;
    DevOps -- "Usa" --> Hubot;
    Hubot -- "Se integra con" --> Slack;
    Hubot -- "Dispara" --> Pipeline_Test;
end
```
