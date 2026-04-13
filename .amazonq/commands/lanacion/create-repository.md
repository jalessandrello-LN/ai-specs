# create-repository

## Descripción
Genera un repositorio completo con entidad de dominio, interface, implementación y script SQL.

## Sintaxis
```
/create-repository [EntityName] [DatabaseType]
```

## Parámetros
- **EntityName** (requerido): Nombre de la entidad (ej: `Product`)
- **DatabaseType** (requerido): Tipo de base de datos (`MySQL`, `PostgreSQL`, `SQLServer`)

## Referencia
Consultar `ai-specs/specs/ln-susc-listener-standards.mdc` para:
- Repository pattern
- Dapper usage
- Database patterns

## Archivos Generados
1. `src/LaNacion.Core.Templates.SqsRdr.Domain/{EntityName}.cs`
2. `src/LaNacion.Core.Templates.SqsRdr.Application.Interfaces/Persistance/I{EntityName}Repository.cs`
3. `src/LaNacion.Core.Templates.SqsRdr.Repositories.SQL/{EntityName}Repository.cs`
4. `scripts/Create{EntityName}Table_{DatabaseType}.sql`

## Configuración DI Requerida
Agregar en `ConfigureServicesExtensions.cs`:
```csharp
.AddScoped<I{EntityName}Repository, {EntityName}Repository>()
```

## Ejemplo
```
/create-repository Product MySQL
```

Genera:
- `Product.cs` (entidad)
- `IProductRepository.cs` (interface)
- `ProductRepository.cs` (implementación MySQL)
- `CreateProductTable_MySQL.sql` (script)
