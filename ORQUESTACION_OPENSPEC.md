# ORQUESTACIÓN DE AGENTES - FLUJO DE TRABAJO OPENSPEC

Este documento describe cómo se orquestan los agentes y skills en el flujo de trabajo OpenSpec para proyectos grandes, desde la planificación hasta la implementación de historias de usuario.

---

## 1. FLUJO PRINCIPAL DEL PROYECTO

### 1.1 Fases del Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    OPENSPEC LARGE PROJECT WORKFLOW                      │
└─────────────────────────────────────────────────────────────────────────┘

Phase 0: Inicialización
    │
    ├─→ openspec init
    └─→ Estructura de proyecto configurada

Phase 1: Planificación
    │
    ├─→ /opsx-new "planning-full-project"
    ├─→ /opsx-ff (fast-forward artifacts)
    ├─→ /opsx-apply (genera backlog: Epics, MVPs, HUs)
    ├─→ /opsx-sync (sincroniza specs)
    └─→ /opsx-archive

Phase 2: Epics
    │
    ├─→ /opsx-new "epic-XX-nombre"
    ├─→ /opsx-ff
    └─→ /opsx-apply + /opsx-sync + /opsx-archive (por cada Epic)

Phase 3: Historias de Usuario (HUs)
    │
    ├─→ /opsx-new "hu-XXX-descripcion"
    ├─→ /opsx-ff
    ├─→ /plan-backend-ticket (genera plan de implementación)
    ├─→ /develop-backend (implementa código)
    ├─→ /opsx-verify
    ├─→ /opsx-sync
    └─→ /opsx-archive (por cada HU)

Phase 4: Implementación Individual
    │
    ├─→ /opsx-apply (ejecuta tasks del plan)
    ├─→ /opsx-verify (valida completitud)
    ├─→ /opsx-sync (delta specs → main)
    └─→ /opsx-archive

Phase 5: Integración y Release
    │
    ├─→ Integration tests
    ├─→ MVP release
    └─→ Despliegue
```

---

## 2. AGENTES INVOLUCRADOS POR FASE

### Phase 0: Inicialización

| Componente | Rol |
|-----------|-----|
| Skill: `openspec-large-project-planning` | Configura el entorno de trabajo |

### Phase 1: Planificación

| Componente | Rol |
|-----------|-----|
| Skill: `openspec-new-change` | Crea nuevo change de planificación |
| Skill: `openspec-ff-change` | Fast-forward de todos los artifacts |
| Skill: `openspec-large-project-planning` | Genera backlog (Epics, MVPs, HUs) |

### Phase 2: Epics

| Componente | Rol |
|-----------|-----|
| Skill: `openspec-new-change` | Crea change de Epic |
| Skill: `openspec-continue-change` | Continúa creación de artifacts |

### Phase 3: Historias de Usuario

| Componente | Rol |
|-----------|-----|
| Skill: `openspec-new-change` | Crea change de HU |
| Command: `/plan-backend-ticket` | Invoca planner para generar plan de implementación |
| Agente: `lanacion-backend-planner` | Genera plan detallado |

### Phase 4: Implementación

| Componente | Rol |
|-----------|-----|
| Command: `/develop-backend` | Deriva agente e implementa código |
| Agente: `lanacion-api-developer` | Implementa APIs |
| Agente: `lanacion-lstnr-developer` | Implementa Listeners |
| Skill: `openspec-verify-change` | Verifica implementación |
| Skill: `openspec-sync-specs` | Sincroniza specs |
| Skill: `openspec-archive-change` | Archiva cambio |

---

## 3. INTERACCIÓN ENTRE AGENTES Y SKILLS

### 3.1 Flujo de Planificación (Phase 1)

```
Usuario: /opsx-new "planning-full-project"
    │
    ├─→ openspec-new-change (skill)
    │   └─→ Crea: openspec/changes/planning-full-project/
    │
    ├─→ /opsx-ff planning-full-project
    │   └─→ openspec-ff-change (skill)
    │       └─→ Genera: proposal.md, design.md, tasks.md, specs/
    │
    └─→ /opsx-apply planning-full-project
        └─→ lanacion-backend-planner (agente)
            └─→ Genera:
                ├─→ Epic backlog (EPIC-01, EPIC-02, ...)
                ├─→ MVP roadmap (MVP 1.1, MVP 1.2, ...)
                └─→ HU list por MVP (HU-001, HU-002, ...)
```

**Salida en `openspec/changes/planning-full-project/`:**
- proposal.md - Alcance del proyecto
- design.md - Decisiones técnicas
- tasks.md - Checklist de planificación
- specs/ - Requisitos por capability
- epic-backlog.md - Lista de Epics
- mvp-roadmap.md - Roadmap de MVPs
- hu-list.md - Lista de HUs por MVP

### 3.2 Flujo de Implementación de HU (Phase 3-4)

```
Usuario: /opsx-new "hu-001-register-customer"
    │
    ├─→ openspec-new-change (skill)
    │   └─→ Crea: openspec/changes/hu-001-register-customer/
    │
    ├─→ /opsx-ff hu-001-register-customer
    │   └─→ Genera artifacts básicos
    │
    ├─→ /plan-backend-ticket hu-001-register-customer
    │   └─→ lanacion-backend-planner
    │       ├─→ Analiza ticket
    │       ├→ Detecta tipo (API)
    │       ├─→ Consulta ln-susc-api-standards.mdc
    │       └─→ Genera: hu-001-register-customer_backend.md
    │
    └─→ /opsx-apply hu-001-register-customer
        └─→ lanacion-api-developer (derivado por command handler)
            ├─→ Implementa: Domain → Application → Infrastructure → API
            ├─→ Ejecuta tests
            ├─→ Valida cobertura 80%+
            └─→ Actualiza documentación
```

**El plan contiene:**
- Backend Type: API
- Template: LaNacion.Core.Templates.Web.Api.Minimal
- Standards: ln-susc-api-standards.mdc
- Steps: Domain → Application → Infrastructure → API → Tests → Docs

---

## 4. ESCENARIOS DE USO

### Escenario 1: Scaffolding de Proyecto Nuevo

**Contexto:** Se necesita crear un nuevo microservicio Listener para procesar eventos de Cobranza.

```
Usuario: /scaffold-listener LN.Sus.Cobranza.Listener
    │
    ├─→ lanacion-nx-monorepo-developer (agente)
    │   ├─→ El usuario define el tipo en el comando
    │   ├─→ Adopta skill: scaffold-monorepo-backend-app
    │   ├─→ Template: ln-SQSlstnr
    │   └─→ Genera estructura completa
    │
    └─→ Estructura creada en src/apps/LN.Sus.Cobranza.Listener/
        ├─→ LN.Sus.Cobranza.Listener.Domain/
        ├─→ LN.Sus.Cobranza.Listener.Domain.Events/
        ├─→ LN.Sus.Cobranza.Listener.Application/
        ├─→ LN.Sus.Cobranza.Listener.Application.Interfaces/
        ├─→ LN.Sus.Cobranza.Listener.Repositories.SQL/
        ├─→ LN.Sus.Cobranza.Listener.Workers/
        ├─→ cdk/ (infraestructura)
        └─→ project.json

Pasos posteriores:
    │
    ├─→ /opsx-new "hu-XXX-procesar-cobranza"
    ├─→ /plan-backend-ticket hu-XXX-procesar-cobranza
    └─→ /develop-backend @hu-XXX-procesar-cobranza_backend.md
```

**Validación:**
- ✅ Proyecto creado bajo `apps/`
- ✅ Template ln-SQSlstnr aplicado
- ✅ Estructura Clean Architecture
- ✅ CDK configurado
- ✅ Listo para implementación de features

### Escenario 2: Agregar Feature a Proyecto Existente

**Contexto:** El proyecto Listener de Cobranza ya existe. Necesitamos agregar funcionalidad para procesar eventos de pago recibido.

```
 Flujo:
    │
    ├─→ /opsx-new "hu-042-procesar-pago-recibido"
    │   └→ Crea change en openspec/changes/
    │
    ├→ /opsx-ff hu-042-procesar-pago-recibido
    │   └→ Genera artifacts (proposal, specs, design, tasks)
    │
    ├→ /plan-backend-ticket hu-042-procesar-pago-recibido
    │   └→ lanacion-backend-planner genera plan
    │       └→ Detecta tipo: Listener (por proyecto existente)
    │
    └→ /opsx-apply hu-042-procesar-pago-recibido
        └→ Command Handler deriva lanacion-lstnr-developer
            ├→ Lee plan
            ├→ Busca: ln-susc-listener-standards.mdc
            ├→ Deriva: lanacion-lstnr-developer
            └→ Implementa en proyecto existente:
                ├→ Domain/Events/PagoRecibidoEvent.cs
                ├→ Application/Commands/ProcesarPagoCommand.cs
                ├→ Application/Handlers/ProcesarPagoHandler.cs
                ├→ Application/Validators/ProcesarPagoValidator.cs
                ├→ Repositories.SQL/PagoRepository.cs
                ├→ Workers/SqsConsumerService.cs
                └→ Tests/
```

### Escenario 3: Flujo Completo de Epic a Release

```
Usuario: /opsx-new "epic-03-cobranza"
    │
    ├─→ Crea estructura de Epic
    │   └→ proposal.md, design.md, tasks.md, specs/
    │
    ├─→ Define capabilities:
    │   ├→ Procesar pagos recibidos
    │   ├→ Calcular deuda actualizada
    │   └→ Generar notificaciones de atraso
    │
    ├─→ Crea MVPs:
    │   ├→ MVP 3.1: Core procesamiento de pagos
    │   └→ MVP 3.2: Notificaciones y deuda
    │
    └→ Por cada HU en los MVPs:
        │
        ├→ /opsx-new "hu-040-procesar-pago"
        ├→ /opsx-ff hu-040-procesar-pago
        ├→ /plan-backend-ticket hu-040-procesar-pago
        ├→ /develop-backend @hu-040-procesar-pago_backend.md
        ├→ /opsx-verify hu-040-procesar-pago
        ├→ /opsx-sync hu-040-procesar-pago
        └→ /opsx-archive hu-040-procesar-pago

Release:
    │
    ├→ /opsx-new "mvp-3.1-release"
    ├→ Integration tests
    └→ Despliegue a producción
```

---

## 5. COHERENCIA DEL FLUJO

### 5.1 Cadena de Dependencias

```
Skill: openspec-new-change
    │
    ├─→ Crea change
    └─→ No tiene dependencias

Skill: openspec-ff-change
    │
    └─→ Depende de: openspec-new-change (change debe existir)

Agente: lanacion-backend-planner
    │
    └─→ Depende de: Ticket ID válido en el change

Command: /develop-backend
    │
    ├─→ Depiende de: Plan generado (TICKET_backend.md)
    └─→ Deriva agente por estándar en plan

Skill: openspec-verify-change
    │
    └─→ Depiende de: Código implementado

Skill: openspec-sync-specs
    │
    └─→ Depiende de: Verify completado

Skill: openspec-archive-change
    │
    └─→ Depiende de: Sync completado
```

### 5.2 Skills que No Intervienen en Orquestación

| Skill | Rol |
|-------|-----|
| `scaffold-monorepo-backend-app` | Genera código (no orquestación) |
| `scaffold-monorepo-lambda` | Genera Lambda (no orquestación) |
| `validate-monorepo-integration` | Valida estructura (no orquestación) |

---

## 6. MATRIZ DE DECISIÓN: API vs LISTENER EN OPENSPEC

| Criterio | API | Listener |
|----------|-----|----------|
| **Comando inicial** | `/opsx-new` + `/plan-backend-ticket` | `/opsx-new` + `/plan-backend-ticket` |
| **Estándar** | ln-susc-api-standards.mdc | ln-susc-listener-standards.mdc |
| **Template** | LaNacion.Core.Templates.Web.Api.Minimal | ln-SQSlstnr |
| **Agente derivado** | lanacion-api-developer | lanacion-lstnr-developer |
| **Archivo de plan** | `[HU]_backend.md` con API | `[HU]_backend.md` con Listener |
| **Directorio destino** | `apps/[Project]/[Project].Api/` | `apps/[Project]/[Project].Workers/` |

---

## 7. VALIDACIÓN DE COHERENCIA

### ✅ Workflow Validado

1. **Fases:**
   - ✅ 5 fases claramente definidas
   - ✅ Dependencias entre fases establecidas
   - ✅ Flujo trazable de inicio a fin

2. **Agentes:**
   - ✅ Agentes utilizados en cada fase
   - ✅ Flujo de derivación (Command → estándares → agente)
   - ✅ Skills para operaciones especializadas

3. **Rutas:**
   - ✅ Planificación → Epic → HU → Implementación
   - ✅ Scaffolding (paralelo al flujo principal)
   - ✅ Agregar feature a proyecto existente

4. **Prefijos:**
   - ✅ HU- para historias de usuario
   - ✅ EPIC- para epics
   - ✅ MVP- para MVPs

5. **Configuration Reference:**
   - ✅ `project.md` contiene: tecnología, estándares, convenciones de naming, patrones de arquitectura, workflow de agentes

---

## 8. CONCLUSIONES

### 8.1 Flujo de Orquestación

El sistema opera con:
- **Skills** para operaciones de workflow (new, ff, apply, verify, sync, archive)
- **Agentes** para implementación de código (planificador, desarrolladores)
- **Commands** como puntos de entrada y derivación

### 8.2 Patrón de Derivación

```
/opsx-new (skill) → Crea change
    │
/opsx-ff (skill) → Genera artifacts
    │
/plan-backend-ticket (command) → Invoca planner
    │
Genera plan con estándares declarados
    │
/develop-backend (command) → Deriva agente
    │
Implementa → /opsx-verify → /opsx-sync → /opsx-archive
```

### 8.3 Escenarios Cubiertos

✅ Scaffolding de proyecto nuevo
✅ Agregar feature a proyecto existente
✅ Flujo completo de Epic a Release
✅ Implementación de múltiples HUs en paralelo

---

*Document Version: 1.2*
*Last Updated: April 24, 2026 - Consolidado con /opsx-* commands*