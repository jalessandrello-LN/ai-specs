# create-sqs-listener

## Descripción
Genera un listener SQS completo usando el template `ln-SQSlstnr` con todos los componentes necesarios: evento, handler, repositorio, entidad y configuración.

## Sintaxis
```bash
dotnet new ln-SQSlstnr -n [ProjectName] -o [OutputPath]
```

## Parámetros
- **ProjectName** (requerido): Nombre del proyecto (PascalCase)
- **OutputPath** (requerido): Ruta donde crear la solución
- **EventName** (requerido): Nombre del evento (ej: `PurchaseOrder_Received`)
- **QueueName** (requerido): Nombre de la cola SQS (kebab-case)
- **EntityName** (requerido): Nombre de la entidad de dominio
- **DatabaseType** (opcional): MySQL (default), PostgreSQL, SQLServer

## Referencia
Consultar `ai-specs/specs/ln-susc-listener-standards.mdc` para:
- Complete architecture patterns
- Event-driven design
- CQRS implementation
- Idempotency patterns

## Flujo de Ejecución

### 1. Crear proyecto desde template
```powershell
cd [OutputPath]
dotnet new ln-SQSlstnr -n [ProjectName]
cd [ProjectName]
```

### 2. Generar componentes personalizados

#### A. Evento de Dominio
**Archivo:** `src/LaNacion.Core.Templates.SqsRdr.Domain.Events/v1/{EventName}.cs`

#### B. Entidad de Dominio
**Archivo:** `src/LaNacion.Core.Templates.SqsRdr.Domain/{EntityName}.cs`

#### C. Interfaz de Repositorio
**Archivo:** `src/LaNacion.Core.Templates.SqsRdr.Application.Interfaces/Persistance/I{EntityName}Repository.cs`

#### D. Implementación de Repositorio
**Archivo:** `src/LaNacion.Core.Templates.SqsRdr.Repositories.SQL/{EntityName}Repository.cs`

#### E. Handler de MediatR
**Archivo:** `src/LaNacion.Core.Templates.SqsRdr.Application/{EventName}Processor.cs`

### 3. Actualizar configuración DI
**Archivo:** `src/LaNacion.Core.Templates.SqsRdr/Workers/ConfigureServicesExtensions.cs`

### 4. Generar script SQL
**Archivo:** `scripts/{EntityName}_DB_Script.sql`

## Validaciones
- ✅ Template `ln-SQSlstnr` instalado
- ✅ OutputPath existe y tiene permisos
- ✅ EventName sigue convención PascalCase con guión bajo
- ✅ QueueName en kebab-case
- ✅ EntityName en PascalCase
- ✅ No hay conflictos de nombres

## Próximos Pasos
1. Compilar: `dotnet build`
2. Configurar `appsettings.json` con URL de cola SQS
3. Ejecutar: `dotnet run`
4. Verificar logs de inicio del listener

## Ejemplo
```
Entrada:
- ProjectName: PurchaseOrderListener
- OutputPath: F:\\PoC
- EventName: PurchaseOrder_Received
- QueueName: purchase-order-processing
- EntityName: Order
- DatabaseType: MySQL
```
