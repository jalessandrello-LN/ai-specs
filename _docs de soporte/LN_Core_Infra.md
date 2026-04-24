
# Reporte de Proyectos de Infraestructura: LaNacion.Core.Infraestructure

Este repositorio contiene una colección de componentes de infraestructura reutilizables, diseñados para ser consumidos como paquetes NuGet y dar soporte a diversas aplicaciones de La Nación, con un fuerte enfoque en servicios de AWS y patrones de desarrollo modernos.

---

### **1. Identidad, Autenticación y Autorización**

Este grupo de proyectos se encarga de la seguridad, la validación de tokens y la integración con proveedores de identidad.

*   **`LaNacion.Core.Infraestructure.AzureAD.Authentication`**: Provee extensiones y manejadores para integrar la autenticación de Azure Active Directory en las APIs, incluyendo la validación de tokens en las cabeceras.
*   **`LaNacion.Core.Infraestructure.AzureAD.Interfaces`**: Define las interfaces para la extensibilidad de la autenticación con Azure AD, como `IAdditionalClaimsProvider`, que permite agregar claims personalizados.
*   **`LaNacion.Core.Infraestructure.JWT.Validation.Configuration`**: Contiene clases de configuración para la validación de tokens JWT.
*   **`LaNacion.Core.Infraestructure.JWT.Validation.Extensions`**: Ofrece métodos de extensión para registrar y configurar fácilmente la validación de JWT en el pipeline de la aplicación.
*   **`LaNacion.Suscripciones.Back.Infraestructure.JWT`**: Parece ser una implementación específica de JWT para el backend del sistema de Suscripciones.

### **2. Configuración y Gestión de Secretos**

Proyectos dedicados a la carga de configuración desde diversas fuentes de forma centralizada y segura.

*   **`LaNacion.Core.Infraestructure.Configuration.AppConfig.FeatureFlags`**: Se integra con AWS AppConfig para gestionar *feature flags* (banderas de funcionalidad), permitiendo activar o desactivar características en tiempo de ejecución.
*   **`LaNacion.Core.Infraestructure.Configuration.ResourcesProvider`**: Permite cargar archivos de configuración (probablemente `appsettings.json` o similares) desde recursos embebidos.
*   **`LaNacion.Core.Infraestructure.SecretMgr`**: Provee una abstracción para acceder a secretos almacenados en AWS Secrets Manager.
*   **`LaNacion.Core.Infraestructure.ParamStore`**: (Inferido por el nombre) Probablemente se integra con AWS Systems Manager Parameter Store para obtener parámetros de configuración.

### **3. Acceso a Datos**

Este es el conjunto más grande de proyectos y cubre la persistencia en diferentes motores de bases de datos, tanto relacionales como NoSQL.

*   **`LaNacion.Core.Infraestructure.Data`**: Define la interfaz genérica `IRepository`, estableciendo un contrato base para los repositorios de datos.
*   **`LaNacion.Core.Infraestructure.Data.Configuration`**: Contiene clases para la configuración de conexiones a bases de datos, como `AWSDynamoDBSettings` y `CnnStringsSection`.
*   **`LaNacion.Core.Infraestructure.Data.DynamoDB`**: Implementación concreta del patrón de repositorio para interactuar con Amazon DynamoDB.
*   **`LaNacion.Core.Infraestructure.Data.Interfaces.DynamoDB`**: Define las interfaces específicas para las operaciones con DynamoDB.
*   **`LaNacion.Core.Infraestructure.Data.KeyValue.Interfaces`**: Define una abstracción para el acceso a bases de datos clave-valor.
*   **`LaNacion.Core.Infraestructure.Data.MySql` / `Postgres` / `SQLServer`**: Proveen extensiones para registrar y configurar el acceso a bases de datos MySQL, PostgreSQL y SQL Server, respectivamente, probablemente usando Entity Framework Core.
*   **`LaNacion.Core.Infraestructure.Data.Relational`**: Componente base para la configuración de bases de datos relacionales.
*   **`LaNacion.Core.Infraestructure.Data.ValKey`**: (Inferido) Posiblemente una integración con la base de datos en memoria Valkey o una abstracción similar.

### 4. Eventos, Mensajería y Comunicación Asíncrona

Componentes para construir arquitecturas orientadas a eventos, facilitando la publicación y suscripción a mensajes.

*   **`LaNacion.Core.Infraestructure.EventBridge` / `SNS` / `SQS`**: Clientes y abstracciones para interactuar con los servicios de mensajería de AWS: EventBridge (para buses de eventos), SNS (para notificaciones pub/sub) y SQS (para colas de mensajes).
*   **`LaNacion.Core.Infraestructure.Events`**: Clases y modelos base para la creación de eventos.
*   **`Events.Publisher`**: Orquesta la publicación de eventos, posiblemente con lógica de reintentos y almacenamiento temporal. Incluye:
    *   **`Interfaces`**: Contratos para los publicadores.
    *   **`MessageBus.Client`**: Un cliente para interactuar con el bus de mensajes.
    *   **`MessagePublisher`**: Implementación del patrón Outbox que garantiza la consistencia transaccional entre el estado de la base de datos y la publicación de eventos.
    *   **`Repository` y `Repository.DynamoDb`**: Repositorios para persistir el estado de los eventos publicados, usando DynamoDB como backend.
*   **`Events.Suscriber`**: Lógica para la recepción y procesamiento de eventos. Incluye:
    *   **`Interfaces`**: Contratos para los suscriptores.
    *   **`Repository` y `Repository.DynamoDb`**: Repositorios para manejar la idempotencia y el estado de los eventos procesados.
*   **`LaNacion.Core.Infraestructure.Messaging`**: (Inferido) Probablemente una capa de abstracción de más alto nivel sobre los servicios de mensajería.

### **5. Bloques de Aplicación y Lógica Transversal (Cross-Cutting)**

Utilidades y extensiones que simplifican tareas comunes en el desarrollo de APIs.

*   **`LaNacion.Core.Infraestructure.Automapper.Extensions`**: Facilita la configuración y el uso de AutoMapper para el mapeo de objetos (ej. DTOs a entidades).
*   **`LaNacion.Core.Infraestructure.Common.Tools`**: Colección de herramientas y utilidades generales, como serializadores JSON personalizados.
*   **`LaNacion.Core.Infraestructure.CORS.Extensions`**: Extensiones para configurar políticas de Cross-Origin Resource Sharing (CORS).
*   **`LaNacion.Core.Infraestructure.Domain` y `Domain.Validation`**: Clases base del dominio y lógica de validación (posiblemente con FluentValidation).
*   **`LaNacion.Core.Infraestructure.HealthChecks.Extensions`**: Permite agregar y configurar *health checks* para monitorear el estado de la aplicación y sus dependencias.
*   **`MediatR.*`**: Integración con la librería MediatR para implementar el patrón CQRS (Command Query Responsibility Segregation). Incluye `BaseRequests`, `Behaviors` (para pipelines de logging, validación, etc.) y `Extensions`.
*   **`LaNacion.Core.Infraestructure.Middlewares`**: Middlewares personalizados para el pipeline de ASP.NET Core (ej. manejo de errores, logging de requests).
*   **`LaNacion.Core.Infraestructure.Swagger.Extensions`**: Simplifica la configuración de Swagger/OpenAPI para la documentación de APIs.

### **6. Integración con otros Servicios de AWS**

*   **`LaNacion.Core.Infraestructure.S3`**: Cliente para interactuar con Amazon S3 (Simple Storage Service) para el almacenamiento de objetos.
*   **`LaNacion.Core.Infraestructure.StepFunctions`**: Abstracciones para iniciar y gestionar flujos de trabajo en AWS Step Functions.

### **7. Logging y Auditoría**

*   **`LaNacion.Core.Infraestructure.LogSendEvents`**: (Inferido) Componente específico para registrar o auditar el envío de eventos, probablemente guardando una traza en un sistema de logging o base de datos.
