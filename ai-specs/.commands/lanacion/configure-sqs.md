# configure-sqs

## Descripción
Genera configuración de cola SQS específica por ambiente con URLs y credenciales apropiadas.

## Sintaxis
```
/configure-sqs [QueueName] [EventType] [Environment]
```

## Parámetros
- **QueueName** (requerido): Nombre de la cola SQS (ej: `product-events`)
- **EventType** (requerido): Tipo de evento (ej: `Product_Created`)
- **Environment** (requerido): Ambiente (`Local`, `Development`, `Staging`, `Production`)

## Referencia
Consultar `ai-specs/specs/ln-susc-listener-standards.mdc` para:
- SQS configuration patterns
- Queue naming conventions
- Environment setup

## Archivos Generados
1. `src/LaNacion.Core.Templates.SqsRdr/appsettings.{Environment}.json`

## Configuración DI Requerida
Agregar en `ConfigureServicesExtensions.cs`:
```csharp
.AddSingleton(new SqsQueueNameService<{EventType}>("{QueueName}"))
.AddHostedService<SqsQueueConsumerService<{EventType}>>()
```

## Comandos AWS CLI

### Para Local (LocalStack)
```bash
# Iniciar LocalStack
docker run -d -p 4566:4566 localstack/localstack

# Crear cola
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name {QueueName}

# Verificar cola
aws --endpoint-url=http://localhost:4566 sqs list-queues
```

### Para Development/Staging/Production
```bash
# Crear cola
aws sqs create-queue --queue-name {QueueName} --region us-east-1

# Configurar permisos
aws sqs set-queue-attributes \
  --queue-url https://sqs.us-east-1.amazonaws.com/123456789012/{QueueName} \
  --attributes VisibilityTimeoutSeconds=300,MessageRetentionPeriod=1209600
```

## Ejemplo
```
/configure-sqs product-events Product_Created Development
```

Genera:
- `appsettings.Development.json` con configuración AWS
- Instrucciones para crear cola en AWS
- Configuración DI requerida
