# plan-listener-ticket

## Descripción
Genera un plan de implementación detallado para un ticket de listener SQS, especializado en procesamiento de eventos con idempotencia, MediatR y Clean Architecture.

## Sintaxis
```
/plan-listener-ticket [TicketId]
```

## Parámetros
- **TicketId** (requerido): ID del ticket Azure DevOps (ej: `HU-42`)

## Referencia
Adoptar el rol de `ai-specs/.agents/lanacion-backend-planner.md` y consultar:
- `ai-specs/specs/ln-susc-listener-standards.mdc`
- `ai-specs/specs/documentation-standards.mdc`

## Proceso

1. Adoptar el rol de `lanacion-backend-planner`
2. Analizar el ticket indicado (via MCP si está disponible, o pedir descripción al usuario)
3. Identificar: evento SQS, entidad afectada, lógica de negocio, cola(s) involucrada(s)
4. Generar el plan siguiendo el template de output

## Output

Documento markdown en `ai-specs/changes/[TicketId]_backend.md` con:

### Estructura del Plan

```
# Backend Implementation Plan: [TicketId] [Feature Name]

## Overview
[Descripción del evento a procesar y su propósito]

**Backend Type**: Listener
**Template**: ln-SQSlstnr
**Architecture**: Clean Architecture + CQRS + Event Processing

## Architecture Context
- Domain: evento (IRequest<ProcessResult>)
- Application: processor (IRequestHandler), validaciones
- Infrastructure: repositorios, Dapper
- Worker: SqsQueueConsumerService, DI registration

## Implementation Steps

### Step 0: Create Feature Branch
Branch: feature/[TicketId]-listener

### Step 1: Domain - Event Class
### Step 2: Application - Processor (con idempotencia)
### Step 3: Infrastructure - Repository Interface
### Step 4: Infrastructure - Repository Implementation (Dapper)
### Step 5: Worker Configuration - DI + SQS registration
### Step 6: Configuration - appsettings.json
### Step 7: Unit Tests (happy path, idempotencia, validación, errores)
### Step 8: Update Technical Documentation

## Implementation Order
## Testing Checklist
## Error Response Format (ProcessResult)
## Dependencies
## Notes
```

## Convenciones aplicadas

- **Evento**: `evt-{squad}-{entity}-{verb-past}` (ej: `evt-susc-suscripcion-creada`)
- **Cola**: `{product}-{env}-sqs-{event}` (ej: `suscripciones-prod-sqs-ventas-alta`)
- **Idempotencia**: siempre verificar existencia antes de procesar
- **ProcessResult**: único mecanismo de respuesta del handler
- **Cobertura**: mínimo 80%

## Ejemplo

```
/plan-listener-ticket HU-42
```

Genera `ai-specs/changes/HU-42_backend.md` con plan completo para listener SQS.
