# create-api-query

## Descripción
Crea un endpoint completo de Web API de solo lectura (Query/Read-Only) siguiendo Clean Architecture y CQRS.

## Sintaxis
```
/create-api-query [Action] [Entity] [Description]
```

## Parámetros
- **Action** (requerido): Acción de lectura (ej: `Get`, `List`, `Search`)
- **Entity** (requerido): Nombre de la entidad (ej: `Usuario`, `Producto`)
- **Description** (requerido): Descripción de la consulta

## Referencia
Consultar `ai-specs/specs/ln-susc-api-standards.mdc` para:
- CQRS Query patterns
- DTO patterns
- REST endpoint conventions
- Repository usage

## Archivos Generados

### 1. Query (Application Layer)
**Archivo**: `Application/Queries/{Action}{Entity}Query.cs`

```csharp
using MediatR;

namespace LaNacion.Suscripciones.Application.Queries
{
    public record {Action}{Entity}Query : IRequest<{Entity}Dto>
    {
        public Guid Id { get; init; }
    }
}
```

### 2. DTO (Application Layer)
**Archivo**: `Application/DTOs/{Entity}Dto.cs`

```csharp
namespace LaNacion.Suscripciones.Application.DTOs
{
    public record {Entity}Dto
    {
        public Guid Id { get; init; }
        public string Name { get; init; }
        public string Description { get; init; }
        public DateTime CreatedAt { get; init; }
    }
}
```

### 3. Handler (Application Layer)
**Archivo**: `Application/Handlers/{Action}{Entity}Handler.cs`

```csharp
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using MediatR;

namespace LaNacion.Suscripciones.Application.Handlers
{
    public class {Action}{Entity}Handler : IRequestHandler<{Action}{Entity}Query, {Entity}Dto>
    {
        private readonly I{Entity}Repository _repository;
        private readonly IMapper _mapper;

        public {Action}{Entity}Handler(
            I{Entity}Repository repository,
            IMapper mapper)
        {
            _repository = repository;
            _mapper = mapper;
        }

        public async Task<{Entity}Dto> Handle({Action}{Entity}Query query, CancellationToken ct)
        {
            var entity = await _repository.GetByIdAsync(query.Id);
            
            if (entity == null)
                throw new NotFoundException($"{Entity} with ID {query.Id} not found");
            
            return _mapper.Map<{Entity}Dto>(entity);
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
            app.MapGet("/api/v1/{entities}/{id:guid}", {Action}{Entity})
                .WithName("{Action}{Entity}")
                .WithTags("{Entities}")
                .Produces<{Entity}Dto>(StatusCodes.Status200OK)
                .Produces(StatusCodes.Status404NotFound);
        }

        private static async Task<IResult> {Action}{Entity}(
            Guid id,
            IMediator mediator)
        {
            var query = new {Action}{Entity}Query { Id = id };
            var result = await mediator.Send(query);
            return Results.Ok(result);
        }
    }
}
```

## REST Naming Conventions

- ✅ Use plural nouns: `/api/v1/usuarios`
- ✅ Use kebab-case: `/api/v1/purchase-orders`
- ✅ Use lowercase
- ✅ Use route parameters: `{id:guid}`

## HTTP Methods for Queries

- `GET /api/v1/usuarios/{id}` - Get by ID
- `GET /api/v1/usuarios` - List all
- `GET /api/v1/usuarios?search=john` - Search with filters

## Key Differences from Commands

- ❌ NO Unit of Work (read-only)
- ❌ NO transactions
- ❌ NO event publishing
- ✅ Use AutoMapper for DTOs
- ✅ Return `Results.Ok()` or `Results.NotFound()`

## Dependency Injection

Agregar en `Program.cs` o `ConfigureServicesExtensions.cs`:

```csharp
services.AddScoped<I{Entity}Repository, {Entity}Repository>();
services.AddMediatR(typeof(Program));
services.AddAutoMapper(typeof(Program));
```

## Ejemplo

```
/create-api-query Get Usuario "Obtener un usuario por su ID"
```

Genera:
- `GetUsuarioQuery.cs` (query)
- `UsuarioDto.cs` (DTO)
- `GetUsuarioHandler.cs` (handler sin transacciones)
- `UsuarioEndpoints.cs` (endpoint GET /api/v1/usuarios/{id})

## Validaciones

- ✅ Query implementa `IRequest<TDto>`
- ✅ Handler NO usa Unit of Work
- ✅ Handler usa AutoMapper
- ✅ Endpoint usa REST conventions
- ✅ Returns 200 OK or 404 Not Found
