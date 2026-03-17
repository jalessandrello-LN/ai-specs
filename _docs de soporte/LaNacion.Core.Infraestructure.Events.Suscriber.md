# LaNacion.Core.Infraestructure.Events.Suscriber

Librería completa para consumir y procesar eventos desde **AWS SQS/SNS** con persistencia, idempotencia automática, reintentos, y soporte para **AWS Step Functions**. Implementa el patrón MediatR-based para procesamiento desacoplado de eventos con backends de persistencia intercambiables (SQL Server, DynamoDB).

**Versión:** 2.3.2 | **Target Framework:** .NET Standard 2.0+ | **Licencia:** LA NACION© 2022

---

## 📋 Tabla de Contenidos

- [Características](#características)
- [Propósito](#propósito)
- [Instalación](#instalación)
- [Arquitectura](#arquitectura)
- [Componentes Principales](#componentes-principales)
- [Guía Rápida](#guía-rápida)
- [Configuración Detallada](#configuración-detallada)
- [Ejemplos Prácticos](#ejemplos-prácticos)
- [Procesamiento de Eventos](#procesamiento-de-eventos)
- [Persistencia](#persistencia)
- [Integración Step Functions](#integración-step-functions)
- [SNS vs SQS](#sns-vs-sqs)
- [Estados y Ciclo de Vida](#estados-y-ciclo-de-vida)
- [Idempotencia y Reintentos](#idempotencia-y-reintentos)
- [Logging y Observabilidad](#logging-y-observabilidad)
- [Limitaciones y Consideraciones](#limitaciones-y-consideraciones)
- [Troubleshooting](#troubleshooting)
- [Contribuir](#contribuir)

---

## ✨ Características

✅ **Consumo de SQS/SNS**: Lectura automática de mensajes con long polling
✅ **Procesamiento MediatR**: Patrón CQRS nativo con commands/queries
✅ **Idempotencia automática**: Validación de duplicados en repositorio
✅ **Reintentos controlados**: Máximo 4 intentos con tracking
✅ **Persistencia dual**: SQL Server y DynamoDB soportados
✅ **AWS Step Functions**: Integración para callbacks y workflows
✅ **SNS/SQS híbrido**: Manejo automático de envelopes SNS
✅ **Raw message detection**: Heurística para detectar raw delivery
✅ **Estados de mensaje**: Ciclo completo Recibido → Procesado/Error
✅ **Eventos genéricos**: TEvent parametrizado para flexibilidad
✅ **BackgroundService**: Servicios de Windows/Linux automáticos
✅ **Logging correlacionado**: Operación ID para trazabilidad
✅ **HTTP timeout configurable**: Control granular de timeouts
✅ **Inyección de Dependencias**: Integración nativa con Microsoft.Extensions

---

## 🎯 Propósito

Este proyecto es la **capa de consumo de eventos** de La Nación. Proporciona:

1. **Lectura desde SQS/SNS**: Polling automático con long polling
2. **Persistencia**: Registra cada mensaje recibido antes de procesar
3. **Idempotencia**: Valida si el mensaje ya fue procesado
4. **Procesamiento desacoplado**: MediatR para lógica de negocio independiente
5. **Manejo de errores**: Reintentos, fallback, y tracking de estado
6. **Step Functions integration**: Mecanismo de callbacks para workflows

**Ideal para:**
- Arquitecturas event-driven
- Microservicios desacoplados
- Procesamiento asincrónico de documentos
- Workflows automáticos con Step Functions
- Sistemas de subscripción a eventos

**No es apropiado para:**
- Procesamiento sincrónico (usa API calls directo)
- Eventos que requieren orden estricto (FIFO tiene limitaciones)
- Latencia crítica < 1 segundo (SQS tiene jitter)

---

## 📦 Instalación

### 3 Paquetes NuGet

**1. Interfaces (Contratos):**
```bash
dotnet add package LaNacion.Core.Infraestructure.Events.Suscriber.Interfaces
```

**2. Implementación Base (SQS/SNS):**
```bash
dotnet add package LaNacion.Core.Infraestructure.Events.Suscriber
```

**3. Persistencia (elige una):**
```bash
# Para SQL Server
dotnet add package LaNacion.Core.Infraestructure.Data.Relational
dotnet add package LaNacion.Core.Infraestructure.Events.Suscriber.Repository

# Para DynamoDB
dotnet add package LaNacion.Core.Infraestructure.Events.Suscriber.Repository.DynamoDb
```

### Dependencias Automáticas

| Dependencia | Versión | Propósito |
|---|---|---|
| `AWSSDK.SQS` | 3.7.2.86+ | Acceso nativo a SQS |
| `AWSSDK.Core` | 3.7.400+ | APIs base de AWS |
| `MediatR` | 10.0.0+ | Patrón CQRS para comandos |
| `Newtonsoft.Json` | 13.0.1+ | Serialización JSON |
| `LaNacion.Core.Infraestructure.Domain` | 1.1.0+ | ProcessResult, IRequest |
| `LaNacion.Core.Infraestructure.Events` | 1.2.3+ | MessageBody, enums |
| `Microsoft.Extensions` | 6.0.0+ | DI, Logging, Hosting |

---

## 🏛️ Arquitectura

```
┌─────────────────────────────────────────┐
│   AWS SQS / SNS                         │
│   (Fuente de mensajes)                  │
└──────────────────┬──────────────────────┘
                   │ Polling continuo
                   ↓
    ┌──────────────────────────────────┐
    │ SqsQueueConsumerService<TEvent>  │
    │ (BackgroundService)              │
    │ - Recibe MessageBody             │
    │ - Valida duplicados              │
    │ - Controla reintentos            │
    └──────────────┬───────────────────┘
                   │
      ┌────────────┴────────────┐
      │                         │
      ↓                         ↓
  ┌────────────┐      ┌──────────────────┐
  │Persistencia│      │    MediatR       │
  │ Repository │      │  IRequest Handler│
  │  (Guardar) │      │  (Procesar)      │
  └────────────┘      └──────────────────┘
      │                         │
  ┌────────────────────────────────────┐
  │  SQL Server / DynamoDB             │
  │  (IReceivedMessageRepository)      │
  └────────────────────────────────────┘
```

**Flujo detallado:**
```
1. SqsQueueConsumerService<TEvent> inicia como BackgroundService
2. Polling continuo: ReceiveMessageAsync cada 1 seg
3. Para cada mensaje:
   a) Extraer MessageBody desde SQS message
   b) Consultar IReceivedMessageRepository
   c) ¿Duplicado? → Saltar o incrementar retry count
   d) ¿Reintentos > 4? → Marcar como Error, continuar
   e) Persistir con estado "Recibido"
   f) Deserializar TEvent desde detail
   g) Send a MediatR mediator.Send(TEvent)
   h) Esperar ProcessResult
   i) Actualizar estado: Procesado o Error
   j) DeleteMessageAsync de SQS
```

---

## 🏗️ Componentes Principales

### 1. **MessageBody** - Envelope de EventBridge

```csharp
public class MessageBody
{
    public int Version { get; set; }
    public Guid Id { get; set; }
    public string DetailType { get; set; }        // "detail-type"
    public string Source { get; set; }            // "la-nacion.orders"
    public string Account { get; set; }           // "123456789"
    public DateTime Time { get; set; }            // "2024-02-19T10:30:00Z"
    public string Region { get; set; }            // "us-east-1"
    public Object[] Resources { get; set; }       // []
    public string TaskToken { get; set; }         // Para Step Functions
    public JObject Detail { get; set; }           // Payload JSON
}

public class LNEvent
{
    public Guid MessageId { get; set; }           // SQS MessageId
    public string ReceiptHandle { get; set; }     // Para DeleteMessage
    public string MD5OfBody { get; set; }         // Checksum
    public MessageBody Body { get; set; }         // Parsed MessageBody
}
```

**Ejemplo de mensaje real:**
```json
{
  "version": "0",
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "detail-type": "OrderCreated",
  "source": "la-nacion.orders",
  "account": "123456789",
  "time": "2024-02-19T10:30:00Z",
  "region": "us-east-1",
  "resources": [],
  "detail": {
    "orderId": "ORD-123",
    "customerId": "CUST-456",
    "amount": 99.99,
    "items": [...]
  },
  "taskToken": "arn:aws:states:us-east-1:123456789:stateMachine:..."
}
```

---

### 2. **SqsQueueConsumerService<TEvent>** - Consumidor Principal

```csharp
public class SqsQueueConsumerService<TEvent> : BackgroundService
    where TEvent : IRequest<ProcessResult>
{
    // Métodos públicos
    protected override async Task ExecuteAsync(CancellationToken stoppingToken);

    // Métodos protegidos (para herencia)
    protected async Task<bool> ProcessMessage(
        Guid operationId,
        Message msg,
        CancellationToken cancellationToken);

    protected static TEvent GetEventData(Message msg);

    protected async Task<Tuple<bool, int, bool>> AlreadyPrcessed(
        Guid messageId,
        string body,
        CancellationToken cancellationToken);
}
```

**Características:**
- BackgroundService automático (inicia con la aplicación)
- Polling cada 1 segundo de SQS
- Long polling: `WaitTimeSeconds` configurable (0-20)
- Manejo de excepciones y retry lógica
- Logging correlacionado con `operationId` (OperationId de MessageBody.Id)

---

### 3. **SnsQueueConsumerService<TEvent>** - Para mensajes SNS

```csharp
public class SnsQueueConsumerService<TEvent> : SqsQueueConsumerService<TEvent>
    where TEvent : IRequest<ProcessResult>
{
    // Métodos override
    protected override TEvent GetEventData(Message msg);

    // Métodos adicionales
    private static bool IsRaw(string body);
    private static string UnwrapSnsMessage(string body);
}
```

**Diferencia clave:** Detecta y desenvuelve envelope SNS automáticamente.

**Heurística de detección SNS:**
```csharp
// ✅ Es SNS si tiene: Message, TopicArn, Type, Signature
{
  "Message": "...",
  "TopicArn": "arn:aws:sns:us-east-1:123456789:my-topic",
  "Type": "Notification",
  "Signature": "..."
}

// ✅ También si raw delivery está activado: solo JSON puro
{
  "orderId": "ORD-123",
  "customerId": "CUST-456"
}
```

---

### 4. **IReceivedMessageRepository** - Persistencia

```csharp
public interface IReceivedMessageRepository
{
    // CRUD base
    Guid Add(Message entity);
    Task<Guid> AddAsync(Message entity, CancellationToken = default);

    // Cambios de estado
    Task MarkAsProcessedAsync(Guid messageId);
    Task MarkAsNotProcessedAsync(Guid messageId, string error);

    // Lectura con estado
    Task<Tuple<Message, int, DomainEventStatus>> GetMessageByIdAsync(Guid messageId);
}
```

**Métodos:**
- `Add()`: Persistir mensaje con estado inicial "Recibido"
- `MarkAsProcessedAsync()`: Cambiar a "Procesado" después de éxito
- `MarkAsNotProcessedAsync()`: Cambiar a "ProcessedError" con descripción
- `GetMessageByIdAsync()`: Obtener mensaje + retry count + estado

**Retorna (Tuple):**
1. `Message`: Entidad persistida
2. `int`: Retry count actual
3. `DomainEventStatus`: Estado del mensaje

---

### 5. **ReceivedMessageRepository SQL Server** - Implementación

```csharp
public class ReceivedMessageRepository : BaseRepository<Message, Guid>, IReceivedMessageRepository
{
    public override async Task<Guid> AddAsync(Message entity, CancellationToken = default)
    {
        // Llamar spMensajesRecibidos_Insert
        // Persistir estado inicial: Received
    }

    public async Task MarkAsProcessedAsync(Guid messageId)
    {
        // Llamar spMensajesRecibidos_Update
        // Cambiar estado a Processed
    }

    public async Task MarkAsNotProcessedAsync(Guid messageId, string error)
    {
        // Llamar spMensajesRecibidos_Update
        // Cambiar estado a ProcessedError
        // Almacenar error
    }
}
```

**Stored Procedures requeridos:**
- `spMensajesRecibidos_Insert`: INSERT con estado
- `spMensajesRecibidos_Update`: UPDATE estado y error
- `spMensajesRecibidos_GetById`: SELECT para verificar duplicados

---

### 6. **ReceivedMessageRepository DynamoDB** - Implementación Alternativa

```csharp
public class ReceivedMessageRepository : BaseRepository<Message, Guid>, IReceivedMessageRepository
{
    private readonly string _tableName;  // Configurable

    // Implementa mismos métodos pero con DynamoDB
    public override async Task<Guid> AddAsync(Message entity, CancellationToken = default)
    {
        // Usar DynamoDBContext.SaveAsync
    }
}
```

**Setup:**
```csharp
// En Program.cs
services.AddAwsDynamoMessageRecivedRepository(
    configuration,
    "ReceivedMessageDynamoDbConfig");
```

---

## 🚀 Guía Rápida

### Paso 1: Definir evento como MediatR IRequest

```csharp
using MediatR;
using LaNacion.Core.Infraestructure.Domain;

public class OrderCreatedEvent : IRequest<ProcessResult>, IStepFunctionTaskEvent
{
    public Guid MessageId { get; set; }
    public string OrderId { get; set; }
    public string CustomerName { get; set; }
    public decimal Amount { get; set; }

    // Opcional: para Step Functions
    public string TaskToken { get; set; }
}
```

---

### Paso 2: Crear Handler MediatR

```csharp
using MediatR;
using LaNacion.Core.Infraestructure.Domain;
using Microsoft.Extensions.Logging;

public class OrderCreatedEventHandler : IRequestHandler<OrderCreatedEvent, ProcessResult>
{
    private readonly IOrderService _orderService;
    private readonly ILogger<OrderCreatedEventHandler> _logger;

    public OrderCreatedEventHandler(
        IOrderService orderService,
        ILogger<OrderCreatedEventHandler> logger)
    {
        _orderService = orderService;
        _logger = logger;
    }

    public async Task<ProcessResult> Handle(
        OrderCreatedEvent request,
        CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation(
                "Procesando pedido {OrderId} para {Customer}",
                request.OrderId,
                request.CustomerName);

            // Lógica de negocio
            await _orderService.ProcessOrderAsync(
                request.OrderId,
                request.CustomerName,
                request.Amount,
                cancellationToken);

            _logger.LogInformation("Pedido {OrderId} procesado exitosamente", request.OrderId);

            return new ProcessResult { Succed = true };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error procesando pedido {OrderId}", request.OrderId);
            return new ProcessResult
            {
                Succed = false,
                ErrorDescription = ex.Message
            };
        }
    }
}
```

---

### Paso 3: Registrar en Program.cs

```csharp
var builder = WebApplication.CreateBuilder(args);

// 1. Registrar MediatR
builder.Services.AddMediatR(typeof(OrderCreatedEventHandler).Assembly);

// 2. Registrar persistencia (SQL Server)
builder.Services
    .AddSqlServerUoW(builder.Configuration, "DefaultConnection")
    .AddScoped<IReceivedMessageRepository,
              LaNacion.Core.Infraestructure.Events.Suscriber.ReceivedMessageRepository>();

// O para DynamoDB:
// services.AddAwsDynamoMessageRecivedRepository(builder.Configuration);

// 3. Registrar nombre de cola
builder.Services.AddTransient(
    new SqsQueueNameService<OrderCreatedEvent>("orders-queue"));

// 4. Registrar como servicio en background
builder.Services.AddHostedService<SqsQueueConsumerService<OrderCreatedEvent>>();

// 5. Registrar servicios de negocio
builder.Services.AddScoped<IOrderService, OrderService>();

var app = builder.Build();
app.Run();
```

---

### Paso 4: Configurar appsettings.json

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=EventsDb;User Id=sa;Password=..."
  },
  "AWSSQSConnectionSettings": {
    "useSQSLocal": true,
    "serverUrl": "localhost",
    "port": 4566,
    "useAccessKey": true,
    "accessKey": "fakeAccessKey",
    "secretKey": "fakeSecretKey",
    "waitTimeSeconds": 20,
    "visibilityTimeout": 120
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "LaNacion.Core.Infraestructure.Events": "Debug"
    }
  }
}
```

---

## ⚙️ Configuración Detallada

### AWSSQSConnectionSettings

```csharp
public class AWSSQSConnectionSettings
{
    // Conexión
    public bool IsContainer { get; set; } = false;        // ¿ECS/EC2?
    public bool useSQSLocal { get; set; } = false;        // ¿Local?
    public string serverUrl { get; set; } = "localhost";  // Host
    public int port { get; set; } = 4566;                 // Puerto

    // Credenciales
    public string accessKey { get; set; } = "KeyId";
    public string secretKey { get; set; } = "Secret";
    public string authenticationRegion { get; set; } = "us-east-1";
    public string regionEndpoint { get; set; } = "us-east-1";
    public bool useAccessKey { get; set; } = true;
    public bool useProfile { get; set; } = true;
    public string profile { get; set; } = "Default";

    // Comportamiento SQS
    public int waitTimeSeconds { get; set; } = 60;        // Long polling
    public int visibilityTimeout { get; set; } = 120;     // Invisibilidad
    public int httpTimeoutSeconds { get; set; } = 120;    // HTTP timeout
}
```

**En appsettings.json:**

```json
{
  "AWSSQSConnectionSettings": {
    "useSQSLocal": true,
    "serverUrl": "localhost",
    "port": 4566,
    "waitTimeSeconds": 20,
    "visibilityTimeout": 300,
    "httpTimeoutSeconds": 180
  }
}
```

**Explicación:**
- `waitTimeSeconds: 20`: Long polling de 20 segundos (máximo)
  - Reduce carga de CPU
  - Más latencia pero no importante para eventos
- `visibilityTimeout: 300`: Mensaje invisible 5 minutos después de recibir
  - Tiempo para procesar el mensaje
  - Si handler tarda más, el mensaje aparece nuevamente en la cola
- `httpTimeoutSeconds: 180`: Timeout total de la operación (3 minutos)

---

### ReceivedMessageDynamoDbConfig

```csharp
public class ReceivedMessageDynamoDbConfig
{
    public const string ConfigSection = "ReceivedMessageDynamoDbConfig";
    public string tableName { get; set; } = "ReceivedMessages";
}
```

**En appsettings.json:**
```json
{
  "ReceivedMessageDynamoDbConfig": {
    "tableName": "events-dev-received-messages"
  }
}
```

---

## 📚 Ejemplos Prácticos

### Ejemplo 1: Consumidor SQS Básico

```csharp
// Evento simple
public class UserRegisteredEvent : IRequest<ProcessResult>
{
    public Guid UserId { get; set; }
    public string Email { get; set; }
    public string Name { get; set; }
}

// Handler
public class UserRegisteredEventHandler : IRequestHandler<UserRegisteredEvent, ProcessResult>
{
    private readonly IUserService _userService;

    public async Task<ProcessResult> Handle(UserRegisteredEvent @event, CancellationToken ct)
    {
        try
        {
            await _userService.SendWelcomeEmailAsync(@event.Email, @event.Name);
            await _userService.InitializeProfileAsync(@event.UserId);
            return new ProcessResult { Succed = true };
        }
        catch (Exception ex)
        {
            return new ProcessResult { Succed = false, ErrorDescription = ex.Message };
        }
    }
}

// Setup
var handler = builder.Host.ConfigureServices(services =>
{
    services.AddMediatR(typeof(UserRegisteredEventHandler).Assembly);
    services.AddScoped<IUserService, UserService>();
    services.AddHostedService<SqsQueueConsumerService<UserRegisteredEvent>>();
    services.AddTransient(new SqsQueueNameService<UserRegisteredEvent>("user-events"));
});
```

---

### Ejemplo 2: Consumidor SNS desde SQS

```csharp
// Evento desde SNS
public class OrderNotificationEvent : IRequest<ProcessResult>
{
    public Guid OrderId { get; set; }
    public string Status { get; set; }  // "Confirmed", "Shipped", "Delivered"
    public string EmailAddress { get; set; }
}

// Handler
public class OrderNotificationHandler : IRequestHandler<OrderNotificationEvent, ProcessResult>
{
    private readonly IEmailService _emailService;

    public async Task<ProcessResult> Handle(OrderNotificationEvent @event, CancellationToken ct)
    {
        try
        {
            var emailContent = GetEmailContent(@event.Status);
            await _emailService.SendAsync(@event.EmailAddress, emailContent);
            return new ProcessResult { Succed = true };
        }
        catch (Exception ex)
        {
            return new ProcessResult { Succed = false, ErrorDescription = ex.Message };
        }
    }

    private string GetEmailContent(string status) => status switch
    {
        "Confirmed" => "Tu pedido ha sido confirmado",
        "Shipped" => "Tu pedido ha sido enviado",
        "Delivered" => "Tu pedido ha sido entregado",
        _ => "Estado desconocido"
    };
}

// Setup (usa SnsQueueConsumerService en lugar de Sqs)
services.AddHostedService<SnsQueueConsumerService<OrderNotificationEvent>>();
services.AddTransient(new SqsQueueNameService<OrderNotificationEvent>("order-notifications-queue"));
```

---

### Ejemplo 3: Integración con Step Functions

```csharp
// Evento con TaskToken para Step Functions callback
public class DataProcessingEvent : IRequest<ProcessResult>, IStepFunctionTaskEvent
{
    public Guid RequestId { get; set; }
    public string FileUrl { get; set; }
    public string TaskToken { get; set; }  // AWS Step Functions token
}

// Handler que notifica el resultado a Step Functions
public class DataProcessingHandler : IRequestHandler<DataProcessingEvent, ProcessResult>
{
    private readonly IAmazonStepFunctions _stepFunctions;
    private readonly IDataProcessingService _dataService;

    public async Task<ProcessResult> Handle(DataProcessingEvent @event, CancellationToken ct)
    {
        try
        {
            var result = await _dataService.ProcessFileAsync(@event.FileUrl);

            // Notificar success a Step Functions
            await _stepFunctions.SendTaskSuccessAsync(
                new SendTaskSuccessRequest
                {
                    TaskToken = @event.TaskToken,
                    Output = JsonConvert.SerializeObject(new { success = true, result })
                });

            return new ProcessResult { Succed = true };
        }
        catch (Exception ex)
        {
            // Notificar failure a Step Functions
            await _stepFunctions.SendTaskFailureAsync(
                new SendTaskFailureRequest
                {
                    TaskToken = @event.TaskToken,
                    Reason = "ProcessingFailed",
                    Cause = ex.Message
                });

            return new ProcessResult { Succed = false, ErrorDescription = ex.Message };
        }
    }
}

// Setup
services.AddAWSService<IAmazonStepFunctions>();
services.AddHostedService<SqsQueueConsumerService<DataProcessingEvent>>();
```

---

### Ejemplo 4: Múltiples Eventos en la Misma Cola

```csharp
// Si tienes múltiples tipos de eventos en la misma cola,
// usa variable de entorno o configuración para determinar el tipo

// En appsettings.json
{
  "EventHandling": {
    "EventType": "OrderCreated"  // O leer desde evento
  }
}

// En Program.cs, registra dinámicamente
var eventType = configuration["EventHandling:EventType"];

if (eventType == "OrderCreated")
{
    services.AddHostedService<SqsQueueConsumerService<OrderCreatedEvent>>();
}
else if (eventType == "UserRegistered")
{
    services.AddHostedService<SqsQueueConsumerService<UserRegisteredEvent>>();
}
```

---

## 📊 Procesamiento de Eventos

### Flujo detallado de una operación:

```
┌─ Mensaje en SQS ─┐
│ {               │
│  "version": 0,  │
│  "id": "...",   │
│  "detail": {}   │
│ }               │
└────────┬────────┘
         │
    PASO 1: RECIBIR
    │ ReceiveMessageAsync()
    │ Se obtiene Message de SQS
    │
    ├─ MessageId: "550e8400-e29b-41d4-a716-446655440000"
    ├─ ReceiptHandle: "AQEBz..."
    ├─ Body: JSON string
    │
    ↓
    PASO 2: ANALIZAR
    │ Parsear MessageBody desde JSON
    │ Extraer detail
    │
    ├─ Detail type: "OrderCreated"
    ├─ Source: "la-nacion.orders"
    ├─ TaskToken: "arn:aws:states:..." (si aplica)
    │
    ↓
    PASO 3: VALIDAR DUPLICADO
    │ IReceivedMessageRepository.GetMessageByIdAsync(Id)
    │
    ├─ ¿Existe? NO → Continuar
    ├─ ¿Existe? SÍ → ¿Retry < 4? → Incrementar retry → Continuar
    ├─ ¿Existe? SÍ → ¿Retry ≥ 4? → Saltar, DeleteMessage
    │
    ↓
    PASO 4: PERSISTIR (RECIBIDO)
    │ IReceivedMessageRepository.AddAsync(Message)
    │ Estado: DomainEventStatus.Received
    │
    ├─ Guardar en BD
    ├─ Registrar timestamp
    │
    ↓
    PASO 5: DESERIALIZAR EVENTO
    │ TEvent GetEventData(Message msg)
    │ JSON detail → OrderCreatedEvent
    │
    ├─ Mapear propiedades
    ├─ Copiar TaskToken si existe
    │
    ↓
    PASO 6: PROCESAR (MEDIATR)
    │ await mediator.Send(newOrderCreatedEvent)
    │ → OrderCreatedEventHandler.Handle()
    │
    ├─ Ejecutar lógica de negocio
    ├─ Retorna ProcessResult
    │
    ├─ ProcessResult.Succed = true  → Éxito
    ├─ ProcessResult.Succed = false → Error
    │
    ↓
    PASO 7: ACTUALIZAR ESTADO
    │
    ├─ SI ÉXITO:
    │  │ MarkAsProcessedAsync(MessageId)
    │  │ Estado: DomainEventStatus.Processed
    │  │
    │  ↓
    ├─ SI ERROR:
    │  │ MarkAsNotProcessedAsync(MessageId, errorMessage)
    │  │ Estado: DomainEventStatus.ProcessedError
    │  │ Guardar ErrorDescription
    │  │
    │  ↓
    ↓
    PASO 8: ELIMINAR DE SQS
    │ DeleteMessageAsync(ReceiptHandle)
    │ Remover de la cola
    │
    ↓
    FIN
    │ Siguiente iteración de polling
    │
    ↓ (a los ~1000ms)
    └─ Vuelta al Paso 1
```

---

## 💾 Persistencia

### Modelo de datos - Tabla MensajesRecibidos

Tanto SQL Server como DynamoDB usan misma estructura:

**Columnas:**
- `Id` (PK): Guid - MessageId del evento
- `Body`: String - Contenido completo JSON
- `Status`: Int - DomainEventStatus
- `RetryCount`: Int - 0-4 reintentos
- `ErrorDescription`: String (nullable) - Descripción del error
- `CreatedAt`: DateTime - Cuándo se recibió
- `ProcessedAt`: DateTime (nullable) - Cuándo se procesó
- `OperationId`: Guid - MessageBody.Id para correlación

**Estados:**
```csharp
public enum DomainEventStatus
{
    Created = 0,           // No usado por suscriptor
    Published = 1,         // No usado por suscriptor
    Received = 2,          // ← Justo después de recibir
    Processed = 3,         // ← Después de éxito
    PublishedError = 11,   // No usado
    ProcessedError = 12    // ← Después de error
}
```

**Flujo de estados:**
```
        ┌─ Recibir
        ↓
    RECEIVED ←─────────────────────────────┐
        │                                   │
        ↓ Procesar (mediator)              │
    ┌─────────┐                            │
    │ Éxito   │  Error                     │
    │         ├─────────────────────────┐  │
    ↓         ↓                         ↓  │
PROCESSED   PROCESSED_ERROR   Retry <4 ─┘
    │           │
    ├─────────┬─┘
    ↓         ↓
DeleteMessage (Salir de SQS)
```

---

## 🔗 Integración Step Functions

### Patrón completo:

**1. Step Function envía evento:**
```
State Machine
  │
  ├─ PutEvents a EventBridge
  │  ├─ Detail: {...}
  │  └─ TaskToken: arn:aws:states:...
  │
  ├─ Espera callback
  └─ Timeout: 1 hora
```

**2. Evento llega a SQS:**
```json
{
  "version": "0",
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "detail-type": "DataProcessing",
  "source": "my-service",
  "detail": { "fileUrl": "s3://..." },
  "taskToken": "arn:aws:states:us-east-1:123456789:token:abc..."
}
```

**3. Handler procesa y reporta:**
```csharp
await stepFunctions.SendTaskSuccessAsync(new SendTaskSuccessRequest
{
    TaskToken = @event.TaskToken,
    Output = JsonConvert.SerializeObject(new {
        status = "completed",
        processedRecords = 1000
    })
});
```

**4. Step Function continúa:**
```
Esperar CallbackTask
  │
  ├─ Recibió Success → Next state
  ├─ Recibió Failure → Error state
  └─ Timeout 1h → Timeout state
```

---

## 🔄 SNS vs SQS

### Cuando usar SQS solo:

```csharp
// 1. Productores directos a SQS
//    SendMessageAsync()

// 2. Consumidor simple
services.AddHostedService<SqsQueueConsumerService<MyEvent>>();
```

### Cuando usar SNS → SQS:

```csharp
// 1. SNS publica a Topic
//    PublishAsync()

// 2. SQS suscrito a Topic
//    EventBridge → SNS → SQS

// 3. Consumidor avanzado
services.AddHostedService<SnsQueueConsumerService<MyEvent>>();
```

**Ventajas SNS → SQS:**
- ✅ Múltiples consumidores sin duplicación
- ✅ Dead Letter Queues automáticas
- ✅ Filtros de mensajes
- ✅ Fan-out a múltiples colas

**Desventajas SNS → SQS:**
- ❌ Una capa extra
- ❌ Más latencia
- ❌ Datos duplicados (envelope)

---

## 📈 Estados y Ciclo de Vida

### Diagrama estado de un mensaje:

```
                   ┌─────────────────────────────┐
                   │   Mensaje en cola SQS       │
                   └──────────────┬──────────────┘
                                  │
                      SqsQueueConsumerService
                      RecieveMessageAsync()
                                  │
                   ┌──────────────┴──────────────┐
                   │                             │
               ¿Duplicado?                  No → Continuar
                   │                             │
                   ├─ Sí + Reintentos < 4       │
                   │  │                    Persistir estado
                   │  └─ Incrementar + Continuar (RECEIVED)
                   │                             │
                   ├─ Sí + Reintentos ≥ 4       │
                   │  │                    Procesar
                   │  └─ Ignorar + DeleteMessage (IRequest Handler)
                   │                             │
                   ├─────────────┬───────────────┤
                   │             │               │
               Éxito        Error/Exception   Timeout
                   │             │               │
           PROCESSED    PROCESSED_ERROR   PROCESSED_ERROR
                   │             │               │
                   └──────┬──────┴───────────────┘
                          │
                   DeleteMessage
                   Salir de SQS
                          │
                     FINAL ESTADO
```

---

## 🔄 Idempotencia y Reintentos

### Garantía de idempotencia:

```csharp
// 1. Mensaje llega por primera vez
//    IReceivedMessageRepository.GetMessageByIdAsync(id)
//    → No existe → Continuar procesamiento

// 2. Handler falla, mensaje se reenvía
//    IReceivedMessageRepository.GetMessageByIdAsync(id)
//    → Existe + retryCount = 1 → Incrementar a 2

// 3. Handler continúa fallando
//    Reintentos: 2, 3, 4
//    Después del 4to intento → MarcarError

// 4. Handler finalmente tiene éxito
//    MarkAsProcessedAsync(id)
//    → marcar como Processed

// 5. Si vuelve a llegar (edge case)
//    Existe + Status = Processed → Ignorar
```

**Control de reintentos:**
```csharp
private async Task<Tuple<bool, int, bool>> AlreadyPrcessed(
    Guid messageId,
    string body,
    CancellationToken cancellationToken)
{
    var (message, retryCount, status) =
        await _repository.GetMessageByIdAsync(messageId, cancellationToken);

    if (message == null)
        return (false, 0, false);  // No existe = procesar

    if (retryCount < 4)
        return (true, retryCount, false);  // Reintentar

    return (true, retryCount, true);  // Max reintentos = ignorar
}
```

---

## 📊 Logging y Observabilidad

### Logs emitidos por operación:

```
[INFO] SqsQueueConsumerService: Iniciando consumidor para OrderCreatedEvent
[DEBUG] RecibiendoMensaje: MessageId=550e8400-e29b..., Body={...}
[DEBUG] AnalizandoEvento: DetailType=OrderCreated, Source=la-nacion.orders
[DEBUG] ValidandoDuplicado: MessageId=550e8400-e29b...
[DEBUG] PersistiendomMensaje: Status=Received, OperationId=550e8400-e29b...
[DEBUG] DeserializandoEvento: TEvent=OrderCreatedEvent
[DEBUG] ProcesandoEnMediatR: Handler=OrderCreatedEventHandler
[INFO] ProcesandoPedido: OrderId=ORD-123, Customer=John Doe
[INFO] PedidoProcesadoExitosamente: OrderId=ORD-123
[DEBUG] ActualizandoEstado: MessageId=550e8400-e29b..., Status=Processed
[DEBUG] EliminandoDelSQS: ReceiptHandle=AQEBz...
[INFO] OperacionCompleta: TiempoTotal=234ms
```

**Configuración en appsettings.json:**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "LaNacion.Core.Infraestructure.Events": "Debug",
      "LaNacion.Core.Infraestructure.Events.Suscriber": "Debug"
    }
  }
}
```

---

## ⚠️ Limitaciones y Consideraciones

### 1. **No garantiza orden estricto**

```csharp
// ❌ No usar si el orden importa
// Mensaje 1, 2, 3 pueden procesarse en orden 3, 1, 2

// ✅ Para orden garantizado: usar FIFO queue
// (con GroupId para particionar por orden)
```

---

### 2. **Reintentos limítados a 4**

```csharp
// ❌ Incorrecto: esperar > 4 reintentos
// Después del 4to fallo, se marca como error y se ignora

// ✅ Correcto: implementar Dead Letter Queue
// Mensajes con error van a DLQ para inspección manual
```

---

### 3. **No soporta muy rápido**

```csharp
// ❌ Insonderable
await repo.BatchWriteAsync(10000);  // Múltiples handlers simultáneamente

// ✅ Correcto: Procesamiento en série (1 mensaje a la vez)
// O configurar MaximumConcurrency en BackgroundService
```

---

### 4. **Visibilidad timeout crítico**

```csharp
// ❌ Incorrecto: visibilityTimeout = 10 segundos
// Si handler tarda 30 segundos → mensaje reaparece en SQS

// ✅ Correcto: visibilityTimeout ≥ máximo tiempo de handler
"visibilityTimeout": 300  // 5 minutos
```

---

### 5. **SQS tiene límites**

```csharp
// Límites SQS:
// - Máximo 256KB por mensaje
// - Máximo 10 attributes
// - Máximo retención 14 días

// ❌ Si el payload > 256KB
// Usar S3 + URI en mensaje

// ✅ Almacenar en S3, pasar referencia
{
  "s3Bucket": "my-bucket",
  "s3Key": "events/file.json"
}
```

---

### 6. **BackgroundService se detiene con la app**

```csharp
// ❌ Incorrecto: Los mensajes se quedan en la cola
// Si la aplicación falla, el mensaje reaparece después del visibilityTimeout

// ✅ Correcto: Manejar shutdown gracefully
// Usar CancellationToken para dejar de procesar nuevos mensajes
```

---

### 7. **DynamoDB cost puede ser alto**

```csharp
// GetMessageByIdAsync = 1 RCU (Read Capacity Unit)
// MarkAsProcessedAsync = 1 WCU
//
// Si procesas 100k mensajes/día:
// - 100k RCU = $0.25 costo de lectura
// - 100k WCU = $1.25 costo de escrituras
// - Total: ~$1.50/día antes de almacenamiento

// ✅ SQL Server más barato para alto volumen
```

---

## 🔧 Troubleshooting

### Error: "Unable to connect to SQS Local"

```
Causa: LocalStack no corriendo
Solución:
docker run -d -p 4566:4566 localstack/localstack
```

---

### Error: "Timed out waiting for task"

```
Causa: visibilityTimeout demasiado bajo
Solución:
"visibilityTimeout": 300  // aumentar a 5 minutos
```

---

### Error: "Handler MediatR no encontrado"

```
Causa: No registraste el handler en DI
Solución:
services.AddMediatR(typeof(MyEventHandler).Assembly);
```

---

### Error: "Message already processed"

```
Causa: El mensaje ya fue procesado (correcto), pero llegó nuevamente
Comportamiento esperado: Se ignora y se elimina de SQS
Verifica: RetryCount en BD < 4
```

---

### Error: "Deserialization failed"

```
Causa: JSON no matchea con TEvent properties
Solución:
1. Verifica que el Detail contiene exactamente lo que espera TEvent
2. Usa JsonConvert.PopulateObject si necesitas mapping custom
```

---

## 🤝 Contribuir

### Reportar Bugs

1. Describe:
   - Versión de librería
   - Versión de .NET
   - Pasos exactos para reproducir

2. Incluye:
   - Stack trace
   - Contenido del mensaje (sin datos sensibles)
   - Logs relevantes

### Sugerir Mejoras

- Abre issue con:
  - Descripción clara
  - Casos de uso
  - Ejemplos deseados

### Contribuir Código

1. Fork el repositorio
2. Crea rama: `git checkout -b feature/tu-feature`
3. Commit con mensajes claros
4. Push a tu fork
5. Abre Pull Request

---

## 📝 Licencia

LA NACION© 2022

---

## 🔗 Referencias Útiles

- [AWS SQS Developer Guide](https://docs.aws.amazon.com/sqs/)
- [AWS SNS Developer Guide](https://docs.aws.amazon.com/sns/)
- [AWS Step Functions](https://docs.aws.amazon.com/stepfunctions/)
- [MediatR Documentation](https://github.com/jbogard/MediatR)
- [AWSSDK.SQS NuGet](https://www.nuget.org/packages/AWSSDK.SQS/)
- [Event-Driven Architecture](https://martinfowler.com/articles/201701-event-driven.html)
- [CQRS Pattern](https://www.martinfowler.com/bliki/CQRS.html)

---

**Última actualización:** Febrero 2026
**Mantenedor:** La Nacion - Equipo de Arquitectura
