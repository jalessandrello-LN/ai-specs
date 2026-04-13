# create-api-endpoint

## Descripción
Crea únicamente el endpoint Minimal API (`IEndpointDefinition`) para un command o query ya existente. Usar cuando el command/query/handler ya están implementados y solo falta exponer el endpoint HTTP.

## Sintaxis
```
/create-api-endpoint [HttpMethod] [Entity] [CommandOrQuery] [Route?]
```

## Parámetros
- **HttpMethod** (requerido): `GET`, `POST`, `PUT`, `DELETE`
- **Entity** (requerido): Nombre de la entidad (ej: `Suscripcion`)
- **CommandOrQuery** (requerido): Nombre del command o query existente (ej: `CreateSuscripcionCommand`, `GetSuscripcionQuery`)
- **Route** (opcional): Ruta personalizada. Si no se indica, se infiere del método y entidad

## Referencia
Consultar `ai-specs/specs/ln-susc-api-standards.mdc` para:
- Minimal API endpoint conventions
- REST naming rules
- HTTP status code mapping

## Archivo Generado

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
            // POST → 201 Created
            app.MapPost("/api/v1/{entities}", {Action}{Entity})
                .WithName("{Action}{Entity}")
                .WithTags("{Entities}")
                .Produces<Guid>(StatusCodes.Status201Created)
                .ProducesValidationProblem();

            // GET → 200 OK
            app.MapGet("/api/v1/{entities}/{id}", Get{Entity})
                .WithName("Get{Entity}")
                .WithTags("{Entities}")
                .Produces<{Entity}Dto>(StatusCodes.Status200OK)
                .Produces(StatusCodes.Status404NotFound);
        }

        private static async Task<IResult> {Action}{Entity}(
            {CommandOrQuery} request,
            IMediator mediator)
        {
            var id = await mediator.Send(request);
            return Results.Created($"/api/v1/{entities}/{id}", new { id });
        }

        private static async Task<IResult> Get{Entity}(
            Guid id,
            IMediator mediator)
        {
            var result = await mediator.Send(new {CommandOrQuery}(id));
            return result is null ? Results.NotFound() : Results.Ok(result);
        }
    }
}
```

## HTTP Status Codes

| Método | Éxito | Error validación | No encontrado |
|--------|-------|-----------------|---------------|
| POST   | 201   | 400             | -             |
| GET    | 200   | -               | 404           |
| PUT    | 200   | 400             | 404           |
| DELETE | 204   | -               | 404           |

## Convenciones REST

- ✅ Plural nouns: `/api/v1/suscripciones`
- ✅ kebab-case: `/api/v1/purchase-orders`
- ❌ Sin verbos en URL: `/crear-suscripcion` ❌
- ❌ Sin trailing slash ❌

## Ejemplo

```
/create-api-endpoint POST Suscripcion CreateSuscripcionCommand
```

Genera `SuscripcionEndpoints.cs` con `MapPost("/api/v1/suscripciones", ...)` delegando a `CreateSuscripcionCommand`.
