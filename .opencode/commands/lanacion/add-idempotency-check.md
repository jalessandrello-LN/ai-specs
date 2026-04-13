# add-idempotency-check

## Descripción
Agrega el patrón de idempotencia a un processor SQS existente usando la tabla `MensajesRecibidos`. Garantiza que mensajes duplicados no sean procesados más de una vez.

## Sintaxis
```
/add-idempotency-check [ProcessorClass] [EventClass]
```

## Parámetros
- **ProcessorClass** (requerido): Nombre de la clase processor existente (ej: `SuscripcionCreadaProcessor`)
- **EventClass** (requerido): Nombre de la clase del evento (ej: `SuscripcionCreada`)

## Referencia
Consultar `ai-specs/specs/ln-susc-listener-standards.mdc` para:
- Idempotency patterns
- MensajesRecibidos table usage
- ProcessResult handling

## Cambios Aplicados

### 1. Agregar dependencia `IMensajesRecibidosRepository`

```csharp
public class {ProcessorClass} : IRequestHandler<{EventClass}, ProcessResult>
{
    private readonly ILogger<{ProcessorClass}> _logger;
    private readonly IUnitOfWork _uoW;
    private readonly I{Entity}Repository _repository;
    private readonly IMensajesRecibidosRepository _mensajesRecibidos; // ← agregar

    public {ProcessorClass}(
        ILogger<{ProcessorClass}> logger,
        IUnitOfWork uoW,
        I{Entity}Repository repository,
        IMensajesRecibidosRepository mensajesRecibidos) // ← agregar
    {
        _logger = logger;
        _uoW = uoW;
        _repository = repository;
        _mensajesRecibidos = mensajesRecibidos; // ← agregar
    }
```

### 2. Agregar check al inicio del Handle

```csharp
public async Task<ProcessResult> Handle({EventClass} @event, CancellationToken ct)
{
    try
    {
        _logger.LogInformation(">>> Processing {EventClass}: Id={Id}", @event.Id);

        // Idempotency check ← agregar este bloque
        var messageKey = $"{nameof({EventClass})}-{@event.Id}";
        if (await _mensajesRecibidos.ExistsAsync(messageKey))
        {
            _logger.LogInformation("Duplicate message detected, skipping: {Key}", messageKey);
            return new ProcessResult { Succed = true, ErrorDescription = "" };
        }

        // ... resto del handler
        using (_uoW.BeginTransaction())
        {
            // lógica de negocio existente

            // Registrar mensaje procesado ← agregar dentro de la transacción
            await _mensajesRecibidos.AddAsync(new MensajeRecibido
            {
                Key = messageKey,
                ReceivedAt = DateTime.UtcNow
            });

            _uoW.Commit();
        }

        return new ProcessResult { Succed = true, ErrorDescription = "" };
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error processing {EventClass}");
        return new ProcessResult { Succed = false, ErrorDescription = ex.Message };
    }
}
```

### 3. Registrar en DI

```csharp
// En ConfigureServicesExtensions.cs
services.AddScoped<IMensajesRecibidosRepository, MensajesRecibidosRepository>();
```

## Tests a Agregar

```csharp
[Fact]
public async Task Handle_DuplicateMessage_SkipsProcessingAndReturnsSuccess()
{
    _mensajesMock.Setup(x => x.ExistsAsync(It.IsAny<string>())).ReturnsAsync(true);

    var result = await _processor.Handle(@event, CancellationToken.None);

    result.Succed.Should().BeTrue();
    _repositoryMock.Verify(x => x.AddAsync(It.IsAny<{Entity}>(), It.IsAny<CancellationToken>()), Times.Never);
    _uowMock.Verify(x => x.Commit(), Times.Never);
}

[Fact]
public async Task Handle_NewMessage_RegistersAndProcesses()
{
    _mensajesMock.Setup(x => x.ExistsAsync(It.IsAny<string>())).ReturnsAsync(false);

    var result = await _processor.Handle(@event, CancellationToken.None);

    result.Succed.Should().BeTrue();
    _mensajesMock.Verify(x => x.AddAsync(It.IsAny<MensajeRecibido>()), Times.Once);
}
```

## Checklist

- [ ] `IMensajesRecibidosRepository` inyectado en constructor
- [ ] Check de duplicado al inicio del Handle
- [ ] Registro del mensaje dentro de la transacción
- [ ] DI registrado en `ConfigureServicesExtensions.cs`
- [ ] Tests de idempotencia agregados
- [ ] Build limpio

## Ejemplo

```
/add-idempotency-check SuscripcionCreadaProcessor SuscripcionCreada
```

Agrega el patrón completo de idempotencia al processor existente.
