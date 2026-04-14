# VALIDACIÓN DE ARQUITECTURA DE ORQUESTACIÓN

## 1. ESTRUCTURA DE AGENTES

### Agente Orquestador Principal
**Archivo:** `ai-specs/.agents/lanacion-nx-monorepo-developer.md`

**Responsabilidades:**
- ✅ Clasificar requerimientos (API, Listener, Lambda)
- ✅ Delegar a skills específicos
- ✅ Validar integración monorepo
- ✅ Garantizar placement correcto bajo `apps/`

**Flujo de Decisión:**
```
Requerimiento
    ↓
¿Es API o Listener?
    ├─→ API → scaffold-monorepo-backend-app (ln-minWebApi)
    ├─→ Listener → scaffold-monorepo-backend-app (ln-SQSlstnr)
    └─→ Lambda → scaffold-monorepo-lambda
    ↓
validate-monorepo-integration
    ↓
Adoptar especialista (lanacion-api-developer o lanacion-lstnr-developer)
```

### Agente Planificador Backend
**Archivo:** `ai-specs/.agents/lanacion-backend-planner.md`

**Responsabilidades:**
- ✅ Analizar tickets
- ✅ Generar planes detallados
- ✅ Crear archivo en `ai-specs/changes/[TICKET-ID]_backend.md`
- ✅ Aplicar estándares correctos (API o Listener)

**Entrada:** Ticket ID (ej: `HU-101`, `HU-202`)
**Salida:** Plan en `ai-specs/changes/HU-XXX_backend.md`

### Agentes Especialistas
**Archivos:**
- `ai-specs/.agents/lanacion-api-developer.md` → Implementación de APIs
- `ai-specs/.agents/lanacion-lstnr-developer.md` → Implementación de Listeners

**Responsabilidades:**
- ✅ Implementar código según plan
- ✅ Seguir estándares específicos
- ✅ Ejecutar tests
- ✅ Validar cobertura 80%+

---

## 2. ESTRUCTURA DE SKILLS

### Skill: scaffold-monorepo-backend-app
**Archivo:** `ai-specs/.skills/scaffold-monorepo-backend-app/SKILL.md`

**Uso:**
- Crear nuevas APIs (ln-minWebApi)
- Crear nuevos Listeners (ln-SQSlstnr)
- Integrar en monorepo automáticamente

**Salida:**
- Proyecto bajo `apps/[ProjectName]/`
- Integrado en `.sln`
- `project.json` configurado
- `cdk/` con infraestructura

### Skill: scaffold-monorepo-lambda
**Archivo:** `ai-specs/.skills/scaffold-monorepo-lambda/SKILL.md`

**Uso:**
- Crear nuevas Lambdas
- Integrar en stack CDK

### Skill: validate-monorepo-integration
**Archivo:** `ai-specs/.skills/validate-monorepo-integration/SKILL.md`

**Uso:**
- Validar después de cada scaffold
- Verificar `.sln`, `project.json`, tests, CDK

---

## 3. FLUJO DE ORQUESTACIÓN PARA REQUERIMIENTOS

### Flujo A: Planificación de Feature (Backend)

```
Usuario: /plan-listener-ticket HU-202
    ↓
lanacion-backend-planner
    ├─ Analiza ticket HU-202
    ├─ Detecta: Listener SQS
    ├─ Consulta: ln-susc-listener-standards.mdc
    └─ Genera: ai-specs/changes/HU-202_backend.md ✅
```

**Validación:**
- ✅ Archivo creado con prefijo correcto: `HU-202`
- ✅ Estructura completa: Domain → Application → Infrastructure → Worker → Tests
- ✅ Estándar aplicado: Listener

### Flujo B: Scaffolding de Proyecto

```
Usuario: /scaffold-listener LN.Sus.Cobros.Listener 20
    ↓
lanacion-nx-monorepo-developer
    ├─ Clasifica: Listener
    ├─ Adopta skill: scaffold-monorepo-backend-app
    ├─ Ejecuta generador con templateType: ln-SQSlstnr
    ├─ Crea: apps/LN.Sus.Cobros.Listener/
    ├─ Integra: .sln, project.json, cdk/
    └─ Valida: validate-monorepo-integration ✅
```

**Validación:**
- ✅ Proyecto creado bajo `apps/`
- ✅ Integrado en `.sln`
- ✅ `project.json` configurado
- ✅ Tests listos

### Flujo C: Implementación de Feature

```
Usuario: implement-backend-plan @HU-202_backend.md
    ↓
lanacion-lstnr-developer (adoptado automáticamente)
    ├─ Lee plan: HU-202_backend.md
    ├─ Implementa: Domain → Application → Infrastructure → Worker
    ├─ Ejecuta tests
    ├─ Valida cobertura: 80%+
    └─ Actualiza documentación ✅
```

**Validación:**
- ✅ Código implementado según plan
- ✅ Tests pasan
- ✅ Cobertura validada
- ✅ Documentación actualizada

---

## 4. COHERENCIA DE PREFIJOS

### Comando: plan-listener-ticket
**Archivo:** `ai-specs/.commands/lanacion/plan-listener-ticket.md`

```
Sintaxis: /plan-listener-ticket [TicketId]
Ejemplo: /plan-listener-ticket HU-42
Salida: ai-specs/changes/HU-42_backend.md
```

✅ **Prefijo validado:** HU-

### Comando: plan-backend-ticket (genérico)
**Archivo:** `ai-specs/.commands/lanacion/plan-backend-ticket.md`

```
Sintaxis: /plan-backend-ticket [TicketId]
Ejemplo: /plan-backend-ticket HU-101
Salida: ai-specs/changes/HU-101_backend.md
```

✅ **Prefijo validado:** HU-

---

## 5. MATRIZ DE DECISIÓN: API vs LISTENER

| Criterio | API | Listener |
|----------|-----|----------|
| **Trigger** | HTTP Request | SQS Event |
| **Patrón** | Request/Response | Event Processing |
| **Estándar** | ln-susc-api-standards.mdc | ln-susc-listener-standards.mdc |
| **Respuesta** | HTTP Status + JSON | ProcessResult |
| **Publicación** | Outbox Pattern | N/A |
| **Idempotencia** | N/A | MensajesRecibidos |
| **Skill** | scaffold-monorepo-backend-app (ln-minWebApi) | scaffold-monorepo-backend-app (ln-SQSlstnr) |
| **Especialista** | lanacion-api-developer | lanacion-lstnr-developer |

---

## 6. VALIDACIÓN DE COHERENCIA

### ✅ Arquitectura Validada

1. **Orquestación:**
   - ✅ Agente orquestador clasifica correctamente
   - ✅ Delega a skills específicos
   - ✅ Adopta especialistas correctos

2. **Planificación:**
   - ✅ Backend planner genera planes detallados
   - ✅ Usa prefijo correcto: HU-
   - ✅ Aplica estándares correctos

3. **Scaffolding:**
   - ✅ Monorepo developer crea proyectos
   - ✅ Integra en monorepo automáticamente
   - ✅ Valida integración

4. **Implementación:**
   - ✅ Especialistas implementan según plan
   - ✅ Ejecutan tests
   - ✅ Validan cobertura

5. **Prefijos:**
   - ✅ Todos los comandos usan HU-
   - ✅ Archivos generados con HU-XXX
   - ✅ Coherencia en todo el flujo

---

## 7. CONCLUSIÓN

✅ **La arquitectura de orquestación es ADECUADA para:**
- Clasificar correctamente entre APIs y Listeners
- Generar planes detallados con prefijo HU-
- Scaffoldear proyectos integrados
- Implementar features de forma autónoma
- Validar coherencia en todo el flujo

✅ **Prefijo HU- está correctamente implementado en:**
- Comandos de planificación
- Archivos generados
- Ejemplos de uso
- Documentación

