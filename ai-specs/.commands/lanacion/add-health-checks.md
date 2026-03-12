# add-health-checks

## Descripción
Genera health checks personalizados con múltiples dependencias y endpoints de monitoreo.

## Sintaxis
```
/add-health-checks [ServiceName] [Dependencies]
```

## Parámetros
- **ServiceName** (requerido): Nombre del servicio (ej: `ProductService`)
- **Dependencies** (requerido): Lista separada por comas (`Database`, `SQS`, `Redis`, `HTTP`)

## Referencia
Consultar `ai-specs/specs/ln-susc-listener-standards.mdc` para:
- Health check patterns
- Monitoring best practices

## Archivos Generados
1. `src/LaNacion.Core.Templates.SqsRdr/HealthChecks/{ServiceName}HealthCheck.cs`
2. `src/LaNacion.Core.Templates.SqsRdr/Extensions/HealthCheckExtensions.cs`
3. `src/LaNacion.Core.Templates.SqsRdr/Endpoints/HealthEndpoints.cs`

## Configuración Program.cs Requerida
```csharp
builder.Services.Add{ServiceName}HealthChecks(builder.Configuration);
app.MapCustomHealthChecks();
```

## Endpoints Disponibles
- `GET /health` - Todos los health checks
- `GET /health/ready` - Solo checks marcados como "ready"
- `GET /health/live` - Liveness probe (siempre healthy)

## Ejemplo
```
/add-health-checks ProductService Database,SQS,Redis
```

Genera:
- `ProductServiceHealthCheck.cs` (health check personalizado)
- `HealthCheckExtensions.cs` (configuración con Database, SQS, Redis)
- `HealthEndpoints.cs` (endpoints JSON)
