# create-api-command

## Descripción
Crea un endpoint completo de Web API que modifica el estado del sistema (Command/Mutation) siguiendo Clean Architecture y CQRS.

## Sintaxis
```
/create-api-command [Action] [Entity] [Description]
```

## Parámetros
- **Action** (requerido): Acción a realizar (ej: `Create`, `Update`, `Delete`)
- **Entity** (requerido): Nombre de la entidad (ej: `Usuario`, `Producto`)
- **Description** (requerido): Descripción del caso de uso

## Referencia
Consultar `ai-specs/specs/ln-susc-api-standards.mdc` para:
- CQRS Command patterns
- Event publishing (Outbox Pattern)
- REST endpoint conventions
- Unit of Work usage

## Archivos Generados

### 1. Command (Application Layer)
**Archivo**: `Application/Commands/{Action}{Entity}Command.cs`

```csharp
using MediatR;

namespace LaNacion.Suscripciones.Application.Commands
{
    public record {Action}{Entity}Command : IRequest<Guid>
    {
        public string Name { get; init; }
        public string Description { get; init; }
    }
}
```

### 2. Validator (Application Layer)
**Archivo**: `Application/Validators/{Action}{Entity}CommandValidator.cs`

```csharp
using FluentValidation;

namespace LaNacion.Suscripciones.Application.Validators
{
    public class {Action}{Entity}CommandValidator : AbstractValidator<{Action}{Entity}Command>
    {
        public {Action}{Entity}CommandValidator()
        {
            RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
            RuleFor(x => x.Description).MaximumLength(500);
        }
    }
}
```

### 3. Handler (Application Layer)
**Archivo**: `Application/Handlers/{Action}{Entity}Handler.cs`

```csharp
using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using LaNacion.Core.Infraestructure.Data.Relational;

namespace LaNacion.Suscripciones.Application.Handlers
{
    public class {Action}{Entity}Handler : IRequestHandler<{Action}{Entity}Command, Guid>
    {
        private readonly IUnitOfWork _uow;
        private readonly I{Entity}Repository _repository;
        private readonly IMessagePublisher _publisher;

        public {Action}{Entity}Handler(
            IUnitOfWork uow,
            I{Entity}Repository repository,
            IMessagePublisher publisher)
        {
            _uow = uow;
            _repository = repository;
            _publisher = publisher;
        }

        public async Task<Guid> Handle({Action}{Entity}Command command, CancellationToken ct)
        {
            using (_uow.BeginTransaction())
            {
                var entity = new {Entity}
                {
                    Id = Guid.NewGuid(),
                    Name = command.Name,
                    Description = command.Description,
                    CreatedAt = DateTime.UtcNow
                };

                await _repository.AddAsync(entity);

                // Publish event inside transaction (Outbox Pattern)
                await _publisher.CreateMessageAsync(
                    "evt-susc-{entity}-{action-past}",
                    new {Entity}{Action}Event
                    {
                        Id = entity.Id,
                        Name = entity.Name,
                        OccurredOnUtc = DateTime.UtcNow
                    }
                );

                _uow.Commit();
                return entity.Id;
            }
        }
    }
}
```

### 4. Endpoint (Presentation Layer)
**Archivo**: `Api/Endpoints/{Entity}Endpoints.cs`

```csharp
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;

namespace LaNacion.Suscripciones.Api.Endpoints
{
    public class {Entity}Endpoints : IEndpointDefinition
    {
        public void DefineEndpoints(WebApplication app)
        {
            app.MapPost("/api/v1/{entities}", {Action}{Entity})
                .WithName("{Action}{Entity}")
                .WithTags("{Entities}")
                .Produces<Guid>(StatusCodes.Status201Created)
                .ProducesValidationProblem();
        }

        private static async Task<IResult> {Action}{Entity}(
            {Action}{Entity}Command command,
            IMediator mediator)
        {
            var id = await mediator.Send(command);
            return Results.Created($"/api/v1/{entities}/{id}", new { id });
        }
    }
}
```

## REST Naming Conventions

- ✅ Use plural nouns: `/api/v1/usuarios`
- ✅ Use kebab-case: `/api/v1/purchase-orders`
- ✅ Use lowercase
- ❌ NO verbs in URLs: `/crear-usuario` ❌
- ❌ NO trailing slashes: `/usuarios/` ❌

## HTTP Methods

- `POST /api/v1/usuarios` - Create
- `PUT /api/v1/usuarios/{id}` - Update
- `DELETE /api/v1/usuarios/{id}` - Delete

## Event Naming

Pattern: `evt-{squad}-{entity}-{verb-past}`

Examples:
- `evt-susc-usuario-creado`
- `evt-susc-producto-actualizado`
- `evt-susc-orden-eliminada`

## Dependency Injection

Agregar en `Program.cs` o `ConfigureServicesExtensions.cs`:

```csharp
services.AddScoped<I{Entity}Repository, {Entity}Repository>();
services.AddMediatR(typeof(Program));
services.AddValidatorsFromAssemblyContaining<{Action}{Entity}CommandValidator>();
```

## Ejemplo

```
/create-api-command Create Usuario "Crear un nuevo usuario con nombre y email"
```

Genera:
- `CreateUsuarioCommand.cs` (command)
- `CreateUsuarioCommandValidator.cs` (validator)
- `CreateUsuarioHandler.cs` (handler con UoW + Event Publishing)
- `UsuarioEndpoints.cs` (endpoint POST /api/v1/usuarios)

## Validaciones

- ✅ Command implementa `IRequest<TResponse>`
- ✅ Validator usa FluentValidation
- ✅ Handler usa Unit of Work
- ✅ Event published inside transaction
- ✅ Endpoint usa REST conventions
- ✅ No try-catch (middleware global maneja errores)
