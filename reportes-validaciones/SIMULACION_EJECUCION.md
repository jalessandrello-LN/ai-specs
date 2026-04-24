# SIMULACIÓN DE EJECUCIÓN: 2 REQUERIMIENTOS

## REQUERIMIENTO 1: API de Actualización de Suscripción

### Entrada
```
Usuario: /plan-backend-ticket HU-101
Descripción: Crear endpoint para actualizar estado de suscripción
```

### Paso 1: Clasificación por Agente Orquestador
```
lanacion-nx-monorepo-developer analiza:
- ¿Es HTTP endpoint? → SÍ
- ¿Es evento SQS? → NO
- ¿Es Lambda? → NO

DECISIÓN: API (Minimal API)
ESTÁNDAR: ln-susc-api-standards.mdc
ESPECIALISTA: lanacion-api-developer
```

### Paso 2: Generación de Plan por Backend Planner
```
lanacion-backend-planner ejecuta:
1. Lee ticket HU-101
2. Detecta: API REST
3. Consulta estándar: ln-susc-api-standards.mdc
4. Genera plan completo

ARCHIVO GENERADO: ai-specs/changes/HU-101_backend.md ✅
PREFIJO: HU-101 ✅
```

### Paso 3: Contenido del Plan Generado
```markdown
# Backend Implementation Plan: HU-101 Update Subscription Status

## Overview
Crear endpoint para actualizar estado de suscripción con validación y publicación de eventos.

**Backend Type**: API
**Template**: LaNacion.Core.Templates.Web.Api.Minimal
**Architecture**: Clean Architecture + CQRS + Event Publishing

## Implementation Steps

### Step 0: Create Feature Branch
Branch: feature/HU-101-api ✅

### Step 1: Domain Layer - Entity
File: Domain/Entities/Subscription.cs
- Entidad Subscription con estados válidos

### Step 2: Application Layer - Command
File: Application/Commands/UpdateSubscriptionStatusCommand.cs
- Command con validación de estado

### Step 3: Application Layer - Validator
File: Application/Validators/UpdateSubscriptionStatusValidator.cs
- Validar estado anterior y nuevo

### Step 4: Application Layer - Handler
File: Application/Handlers/UpdateSubscriptionStatusHandler.cs
- Lógica de negocio
- Publicar evento: evt-susc-suscripcion-estado-actualizado

### Step 5: Infrastructure - Repository Interface
File: Application.Interfaces/Persistance/ISubscriptionRepository.cs

### Step 6: Infrastructure - Repository Implementation
File: Repositories.SQL/SubscriptionRepository.cs
- Implementar con Dapper

### Step 7: Presentation Layer - Endpoint
File: Api/Endpoints/SubscriptionEndpoints.cs
- PUT /api/v1/subscriptions/{id}/status
- Status codes: 200, 400, 404, 500

### Step 8: Dependency Injection
File: Program.cs
- Registrar servicios

### Step 9: Configuration
File: appsettings.json
- Configuración necesaria

### Step 10: Unit Tests
File: Tests/UpdateSubscriptionStatusTests.cs
- Happy path
- Validación
- Error handling
- Cobertura: 80%+

### Step 11: Update Documentation
- Actualizar: ai-specs/specs/api-spec.yml
- Actualizar: ai-specs/specs/data-model.md
```

✅ **Plan generado correctamente con prefijo HU-101**

---

## REQUERIMIENTO 2: Listener SQS de Procesamiento de Cobros

### Entrada
```
Usuario: /plan-listener-ticket HU-202
Descripción: Procesar eventos de cambio de estado de cobro
```

### Paso 1: Clasificación por Agente Orquestador
```
lanacion-nx-monorepo-developer analiza:
- ¿Es HTTP endpoint? → NO
- ¿Es evento SQS? → SÍ
- ¿Es Lambda? → NO

DECISIÓN: Listener (SQS Event Processing)
ESTÁNDAR: ln-susc-listener-standards.mdc
ESPECIALISTA: lanacion-lstnr-developer
```

### Paso 2: Generación de Plan por Backend Planner
```
lanacion-backend-planner ejecuta:
1. Lee ticket HU-202
2. Detecta: SQS Listener
3. Consulta estándar: ln-susc-listener-standards.mdc
4. Genera plan completo

ARCHIVO GENERADO: ai-specs/changes/HU-202_backend.md ✅
PREFIJO: HU-202 ✅
```

### Paso 3: Contenido del Plan Generado
```markdown
# Backend Implementation Plan: HU-202 Process Payment Status

## Overview
Procesar eventos de cambio de estado de cobro desde SQS con idempotencia.

**Backend Type**: Listener
**Template**: ln-SQSlstnr
**Architecture**: Clean Architecture + CQRS + Event Processing

## Implementation Steps

### Step 0: Create Feature Branch
Branch: feature/HU-202-listener ✅

### Step 1: Domain Layer - Event
File: Domain/Events/v1/PaymentStatusChangedEvent.cs
- Event: evt-cobros-pago-procesado
- Propiedades: paymentId, status, timestamp

### Step 2: Application Layer - Processor
File: Application/Processors/PaymentStatusChangedProcessor.cs
- IRequestHandler<PaymentStatusChangedEvent, ProcessResult>
- Implementar idempotencia

### Step 3: Application Layer - Validator
File: Application/Validators/PaymentStatusChangedValidator.cs
- Validar evento

### Step 4: Infrastructure - Repository Interface
File: Application.Interfaces/Persistance/IPaymentRepository.cs
File: Application.Interfaces/Persistance/IMensajesRecibidosRepository.cs

### Step 5: Infrastructure - Repository Implementation
File: Repositories.SQL/PaymentRepository.cs
File: Repositories.SQL/MensajesRecibidosRepository.cs
- Implementar con Dapper
- Idempotencia: verificar MensajesRecibidos

### Step 6: Worker Configuration
File: Workers/ConfigureServicesExtensions.cs
- Registrar SQS consumer
- Cola: suscripciones-prod-sqs-cobros-resultado

### Step 7: Configuration
File: appsettings.json
- Configuración de cola SQS

### Step 8: Unit Tests
File: Tests/PaymentStatusChangedTests.cs
- Happy path
- Idempotencia (mensaje duplicado)
- Validación
- Error handling
- Cobertura: 80%+

### Step 9: Update Documentation
- Actualizar: ai-specs/specs/data-model.md
- Documentar evento: evt-cobros-pago-procesado
```

✅ **Plan generado correctamente con prefijo HU-202**

---

## VALIDACIÓN DE COHERENCIA

### ✅ Requerimiento 1 (HU-101 - API)

| Aspecto | Validación |
|---------|-----------|
| **Prefijo** | ✅ HU-101 |
| **Tipo Detectado** | ✅ API |
| **Estándar Aplicado** | ✅ ln-susc-api-standards.mdc |
| **Especialista** | ✅ lanacion-api-developer |
| **Archivo Generado** | ✅ ai-specs/changes/HU-101_backend.md |
| **Estructura** | ✅ Domain → Application → Infrastructure → Presentation → Tests |
| **Eventos** | ✅ Outbox Pattern |
| **Cobertura Tests** | ✅ 80%+ |

### ✅ Requerimiento 2 (HU-202 - Listener)

| Aspecto | Validación |
|---------|-----------|
| **Prefijo** | ✅ HU-202 |
| **Tipo Detectado** | ✅ Listener |
| **Estándar Aplicado** | ✅ ln-susc-listener-standards.mdc |
| **Especialista** | ✅ lanacion-lstnr-developer |
| **Archivo Generado** | ✅ ai-specs/changes/HU-202_backend.md |
| **Estructura** | ✅ Domain → Application → Infrastructure → Worker → Tests |
| **Idempotencia** | ✅ MensajesRecibidos |
| **ProcessResult** | ✅ Handling correcto |
| **Cobertura Tests** | ✅ 80%+ |

---

## CONCLUSIÓN DE SIMULACIÓN

### ✅ Arquitectura Funciona Correctamente

1. **Clasificación:** Ambos requerimientos fueron clasificados correctamente
   - HU-101 → API ✅
   - HU-202 → Listener ✅

2. **Generación de Planes:** Ambos planes generados con prefijo correcto
   - HU-101_backend.md ✅
   - HU-202_backend.md ✅

3. **Estándares Aplicados:** Cada tipo recibió el estándar correcto
   - API: ln-susc-api-standards.mdc ✅
   - Listener: ln-susc-listener-standards.mdc ✅

4. **Especialistas Adoptados:** Agentes correctos para cada tipo
   - API: lanacion-api-developer ✅
   - Listener: lanacion-lstnr-developer ✅

5. **Coherencia de Prefijos:** Todos los tickets usan HU-
   - Comandos: /plan-listener-ticket HU-202 ✅
   - Archivos: HU-202_backend.md ✅
   - Planes: Referencia HU-202 ✅

### ✅ Prefijo HU- Validado en Todo el Flujo

- ✅ Comandos de entrada
- ✅ Archivos generados
- ✅ Planes de implementación
- ✅ Ramas de feature
- ✅ Documentación

