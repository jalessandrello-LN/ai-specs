# Patrón Outbox - Implementación en Suscripciones API

## Resumen

El patrón Outbox está implementado utilizando la infraestructura estándar de La Nación (`LaNacion.Core.Infraestructure.Events.Publisher.MessagePublisher`) para garantizar la consistencia transaccional entre los cambios de estado del dominio y la publicación de eventos a sistemas externos.

## Componentes de la Implementación

### 1. MessagePublisher (LaNacion.Core.Infraestructure)
- **Ubicación**: `LaNacion.Core.Infraestructure.Events.Publisher.MessagePublisher`
- **Propósito**: Implementación base del publicador de mensajes
- **Configuración**: Se registra mediante `AddMessagesOutBox(configuration)` en `EndPointDefinition.AddCustomerServices`

### 2. TransactionalOutboxMessagePublisher (Decorator)
- **Ubicación**: `LaNacion.Suscripciones.Application.Decorators.TransactionalOutboxMessagePublisher`
- **Propósito**: Intercepta la publicación de eventos y los almacena en la tabla Outbox
- **Funcionalidad**: 
  - Serializa eventos de dominio como `OutboxMessage`
  - Los almacena en la misma transacción que los cambios de datos
  - Si no hay transacción activa, publica inmediatamente

### 3. OutboxProcessor (Background Service)
- **Ubicación**: `LaNacion.Suscripciones.Application.BackgroundServices.OutboxProcessor`
- **Propósito**: Procesa mensajes pendientes de la tabla Outbox
- **Configuración**: Se registra como `HostedService` en `Program.cs`

### 4. OutboxMessage (Entidad de Dominio)
- **Ubicación**: `LaNacion.Suscripciones.Domain.OutboxMessage`
- **Propósito**: Representa un evento almacenado para publicación asíncrona
- **Atributos**:
  - `Id`: Identificador único del mensaje
  - `Type`: Tipo del evento (AssemblyQualifiedName)
  - `Data`: Datos serializados del evento (JSON)
  - `OccurredOnUtc`: Timestamp de creación
  - `Subject`: Asunto del evento
  - `Source`: Origen del evento
  - `DataSchema`: Esquema de los datos
  - `ProcessedOnUtc`: Timestamp de procesamiento (nullable)

### 5. IOutboxMessageRepository
- **Ubicación**: `LaNacion.Suscripciones.Application.Interfaces.Persistance.IOutboxMessageRepository`
- **Implementación**: `LaNacion.Suscripciones.Repositories.SQL.OutboxMessageRepository`
- **Propósito**: Gestiona la persistencia de mensajes Outbox

## Flujo de Funcionamiento

### 1. Escritura Transaccional
```csharp
// En un Command Handler
public async Task<Result> Handle(CreateCustomerCommand request, CancellationToken cancellationToken)
{
    // 1. Modificar entidades de dominio
    var customer = new Customer(request.Name, request.Email);
    await _customerRepository.AddAsync(customer);
    
    // 2. El TransactionalOutboxMessagePublisher intercepta y almacena en Outbox
    await _messagePublisher.CreateMessageAsync<CustomerCreated, CustomerCreatedEvent>(
        customer.Id, 
        new CustomerCreated { Id = customer.Id, Name = customer.Name },
        "customer.created",
        "suscripciones-api",
        "v1/customer-created"
    );
    
    // 3. Commit de la transacción (incluye tanto customer como outbox message)
    await _unitOfWork.SaveChangesAsync();
}
```

### 2. Procesamiento Asíncrono
```csharp
// OutboxProcessor ejecuta periódicamente
public async Task ProcessPendingMessages()
{
    var pendingMessages = await _outboxRepository.GetPendingMessagesAsync();
    
    foreach (var message in pendingMessages)
    {
        try
        {
            // Publicar a EventBridge/SNS
            await _actualMessagePublisher.PublishAsync(message);
            
            // Marcar como procesado
            message.ProcessedOnUtc = DateTime.UtcNow;
            await _outboxRepository.UpdateAsync(message);
        }
        catch (Exception ex)
        {
            // Log error, el mensaje permanece pendiente para reintento
            _logger.LogError(ex, "Error processing outbox message {MessageId}", message.Id);
        }
    }
}
```

## Configuración en Program.cs

```csharp
// Registro de servicios Outbox
builder.Services.AddScoped<IOutboxMessageRepository, OutboxMessageRepository>();
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddHostedService<OutboxProcessor>();

// Decoración manual del IMessagePublisher
var publisherDescriptor = builder.Services.FirstOrDefault(d => d.ServiceType == typeof(IMessagePublisher));
if (publisherDescriptor != null)
{
    builder.Services.Remove(publisherDescriptor);
    builder.Services.Add(new ServiceDescriptor(publisherDescriptor.ImplementationType, publisherDescriptor.ImplementationType, ServiceLifetime.Transient));
    
    builder.Services.AddScoped<IMessagePublisher>(provider =>
        new TransactionalOutboxMessagePublisher(
            (IMessagePublisher)provider.GetRequiredService(publisherDescriptor.ImplementationType),
            provider.GetRequiredService<IOutboxMessageRepository>(),
            provider.GetRequiredService<IUnitOfWork>()
        )
    );
}
```

## Configuración en EndPointDefinition

```csharp
public static IServiceCollection AddCustomerServices(this IServiceCollection services, IConfiguration configuration)
{
    // ... configuración de base de datos ...
    
    services.AddTransient<IAddressRepository, SQL.AddressRepository>()
            .AddTransient<ICustomerRepository, SQL.CustomerRepository>()
            .AddMessagesOutBox(configuration); // ← Configuración del MessagePublisher base
    
    return services;
}
```

## Esquema de Base de Datos

```sql
CREATE TABLE OutboxMessage (
    Id VARCHAR(36) PRIMARY KEY,
    Type VARCHAR(500) NOT NULL,
    Data TEXT NOT NULL,
    OccurredOnUtc DATETIME NOT NULL,
    ProcessedOnUtc DATETIME NULL,
    Subject VARCHAR(200) NOT NULL,
    Source VARCHAR(100) NOT NULL,
    DataSchema VARCHAR(100) NOT NULL,
    INDEX IX_OutboxMessage_ProcessedOnUtc (ProcessedOnUtc),
    INDEX IX_OutboxMessage_OccurredOnUtc (OccurredOnUtc)
);
```

## Ventajas de esta Implementación

1. **Consistencia Transaccional**: Los eventos se almacenan en la misma transacción que los cambios de datos
2. **Tolerancia a Fallos**: Si la publicación falla, los eventos permanecen para reintento
3. **Idempotencia**: Los mensajes procesados se marcan para evitar duplicados
4. **Observabilidad**: Todos los eventos quedan registrados para auditoría
5. **Escalabilidad**: El procesamiento asíncrono no bloquea las operaciones principales
6. **Reutilización**: Utiliza la infraestructura estándar de La Nación

## Consideraciones de Rendimiento

- **Limpieza de Mensajes**: Implementar un proceso para limpiar mensajes procesados antiguos
- **Batch Processing**: El OutboxProcessor puede procesar mensajes en lotes para mejor rendimiento
- **Retry Logic**: Implementar lógica de reintentos con backoff exponencial
- **Monitoring**: Monitorear la cola de mensajes pendientes para detectar problemas

## Eventos de Dominio Típicos

En el contexto de Suscripciones, los eventos típicos incluyen:

- `SuscripcionCreada`
- `SuscripcionSuspendida`
- `SuscripcionRehabilitada`
- `SuscripcionCancelada`
- `BundleCreado`
- `BundleModificado`
- `CondicionComercialVersionada`

Cada evento se almacena en la tabla Outbox y se publica a EventBridge para que otros servicios (Facturación, CRM, etc.) puedan reaccionar apropiadamente.
