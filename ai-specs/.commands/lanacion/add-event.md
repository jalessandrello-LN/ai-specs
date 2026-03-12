# add-event

## Descripción
Agrega un nuevo evento y handler a un listener SQS existente.

## Sintaxis
```
/add-event [EventName] [QueueName] [HandlerLogic?]
```

## Parámetros
- **EventName** (requerido): Nombre del evento (ej: `Customer_Updated`)
- **QueueName** (requerido): Nombre de la cola SQS (ej: `customer-updates`)
- **HandlerLogic** (opcional): Descripción de la lógica personalizada

## Referencia
Consultar `ai-specs/specs/ln-susc-listener-standards.mdc` para:
- Event naming conventions
- Handler patterns
- ProcessResult usage

## Archivos Generados
1. `src/LaNacion.Core.Templates.SqsRdr.Domain.Events/v1/{EventName}.cs`
2. `src/LaNacion.Core.Templates.SqsRdr.Application/{EventName}Processor.cs`

## Template: Evento
```csharp
using System;
using LaNacion.Core.Infraestructure.Domain.Entities;
using MediatR;

namespace LaNacion.Core.Templates.SqsRdr.Domain.Events.v1
{
    public class {EventName} : IRequest<ProcessResult>
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
```

## Template: Handler
```csharp
using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using LaNacion.Core.Templates.SqsRdr.Domain.Events.v1;
using LaNacion.Core.Infraestructure.Domain.Entities;
using LaNacion.Core.Infraestructure.Data.Relational;

namespace LaNacion.Core.Templates.SqsRdr.Application
{
    public class {EventName}Processor : IRequestHandler<{EventName}, ProcessResult>
    {
        private readonly ILogger<{EventName}Processor> _logger;
        private readonly IUnitOfWork _uoW;

        public {EventName}Processor(
            ILogger<{EventName}Processor> logger,
            IUnitOfWork uoW)
        {
            _logger = logger;
            _uoW = uoW;
        }

        public async Task<ProcessResult> Handle({EventName} @event, CancellationToken cancellationToken)
        {
            try
            {
                _logger.LogInformation(">>> Procesando {EventName}: Id={Id}", @event.Id);

                if (@event.Id == Guid.Empty)
                    return new ProcessResult { Succed = false, ErrorDescription = "ID requerido" };

                using (_uoW.BeginTransaction())
                {
                    // TODO: {HandlerLogic}
                    
                    _uoW.Commit();
                }

                _logger.LogInformation("<<< {EventName} procesado exitosamente");
                return new ProcessResult { Succed = true, ErrorDescription = "" };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error procesando {EventName}");
                return new ProcessResult { Succed = false, ErrorDescription = ex.Message };
            }
        }
    }
}
```

## Configuración DI Requerida
Agregar en `ConfigureServicesExtensions.cs`:
```csharp
.AddSingleton(new SqsQueueNameService<{EventName}>("{QueueName}"))
.AddHostedService<SqsQueueConsumerService<{EventName}>>()
```

## Ejemplo
```
/add-event Customer_Updated customer-updates "Actualizar datos de cliente existente"
```

Genera:
- `Customer_Updated.cs` (evento)
- `Customer_UpdatedProcessor.cs` (handler con TODO personalizado)
