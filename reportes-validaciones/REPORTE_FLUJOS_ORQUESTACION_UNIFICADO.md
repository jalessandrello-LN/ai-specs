# Reporte Unificado de Flujos de Trabajo (Agentes + Skills + Comandos)

**Guía primaria**: `D:\template\ai-specs\ORQUESTACION_OPENSPEC.md`  
**Fuentes complementarias**:
- `D:\template\ai-specs\OPENSPEC-LARGE-PROJECT-WORKFLOW.md`
- `D:\template\ai-specs\OPENSPEC-COMMANDS.md`
- `D:\template\ai-specs\ai-specs\.commands\lanacion\README.md`
- Inventario real de: `D:\template\ai-specs\ai-specs\.agents`, `D:\template\ai-specs\ai-specs\.skills`, `D:\template\ai-specs\ai-specs\.commands`

## 1) Modelo mental (qué orquesta qué)

Según `ORQUESTACION_OPENSPEC.md`, el sistema se entiende como:

- **Comandos**: puntos de entrada (“router” de intención). Ej: `/plan-backend-ticket`, `/develop-backend`, `/scaffold-api`.
- **Skills**: ejecución operacional repetible (creación/avance/verificación/sync/archive; scaffold e integración monorepo; implementación guiada por plan).
- **Agentes**: expertise de dominio/técnica (planificación, implementación API, implementación Listener, monorepo routing).

### Roles clave

- **OpenSpec workflow**: se ejecuta principalmente vía `/opsx-*` (o skills `openspec-*` como alternativa).
- **Planning backend**: `lanacion-backend-planner` produce un plan implementable end-to-end.
- **Implementación backend**: `lanacion-api-developer` o `lanacion-lstnr-developer` ejecutan la implementación (normalmente orquestados por `/develop-backend` o por el skill `implement-backend-plan`).
- **Scaffolding monorepo**: `lanacion-nx-monorepo-developer` enruta hacia skills de scaffold y valida integración.

## 2) Inventario (resumen operativo)

### Agentes (`ai-specs/.agents`)
- `product-strategy-analyst` → enriquecer user story / criterios.
- `lanacion-backend-planner` → plan detallado (API o Listener) a `ai-specs/changes/[TICKET]_backend.md`.
- `lanacion-api-developer` → implementar APIs (Minimal API, CQRS, Outbox).
- `lanacion-lstnr-developer` → implementar listeners (SQS, MediatR processors, idempotencia).
- `lanacion-nx-monorepo-developer` → routing/orquestación de scaffolding monorepo (API/Listener/Lambda).
- `frontend-developer` → implementación frontend (fuera del foco de este reporte).

### Skills (`ai-specs/.skills`)
- **OpenSpec (workflow)**: `openspec-new-change`, `openspec-continue-change`, `openspec-ff-change`, `openspec-verify-change`, `openspec-sync-specs`, `openspec-archive-change`.
- **Large planning**: `openspec-large-project-planning` (Phase 0/1 según guía).
- **Implementation**: `implement-backend-plan`, `implement-frontend-plan`.
- **Monorepo**: `scaffold-monorepo-backend-app`, `scaffold-monorepo-lambda`, `validate-monorepo-integration`.

### Comandos (`ai-specs/.commands`)
- Workflow OpenSpec: `/opsx-new`, `/opsx-continue`, `/opsx-ff-change`, `/opsx-status`, `/opsx-apply`, `/opsx-verify`, `/opsx-sync-specs`, `/opsx-archive`.
- Planning/Dev: `/enrich-us`, `/plan-backend-ticket`, `/develop-backend`, `/plan-large-project`.
- Monorepo (La Nación): `/scaffold-api`, `/scaffold-listener`, `/scaffold-lambda`, `/validate-monorepo`.
- Construcción de features: `/create-api-command`, `/create-api-query`, `/create-api-endpoint`, `/integrate-wcf-service`, `/create-sqs-listener`, `/add-event`, `/add-idempotency-check`, `/configure-sqs`, `/add-health-checks`, `/create-repository`, `/cleanup-template-boilerplate`.

## 3) Flujos de trabajo derivados de `ORQUESTACION_OPENSPEC.md`

### 3.1 Phase 0–1: Inicialización + Planificación (Large Project)

**Objetivo**: generar backlog trazable (Epics, MVPs, HUs) desde documentos (Vision + arquitectura + project).

Camino recomendado (comandos):
1. `openspec init`
2. `/opsx-new "planning-full-project"`
3. `/opsx-ff "planning-full-project"`
4. `/opsx-apply "planning-full-project"` → genera backlog (Epics/MVPs/HUs)
5. `/opsx-sync-specs --change "planning-full-project"`
6. `/opsx-archive --change "planning-full-project"`

Orquestación alternativa (skills):
- `openspec-new-change` → `openspec-ff-change` → `openspec-large-project-planning` → `openspec-sync-specs` → `openspec-archive-change`

**Output principal**:
- Workspace OpenSpec actualizado: `openspec/changes/...` y luego `openspec/specs/...` tras sync.

### 3.2 Phase 2: Epics (ciclo por Epic)

**Objetivo**: capturar alcance y cortes de entrega (MVPs) por epic.

Camino recomendado:
1. `/opsx-new "epic-XX-nombre" --schema epic`
2. `/opsx-ff "epic-XX-nombre"`
3. `/opsx-apply "epic-XX-nombre"`
4. `/opsx-sync-specs --change "epic-XX-nombre"`
5. `/opsx-archive --change "epic-XX-nombre"`

**Output**:
- Spec consolidada del epic (según esquema y sync) en `openspec/specs/...`.

### 3.3 Phase 3: Historias de Usuario (HU) con implementación backend

**Objetivo**: ejecutar HU end-to-end, con plan técnico cuando hay backend.

Camino recomendado (según guía):
1. `/opsx-new "hu-XXX-descripcion" --schema hu`
2. `/opsx-ff "hu-XXX-descripcion"`
3. `/plan-backend-ticket HU-XXX` → adopta `lanacion-backend-planner`
4. Output: `ai-specs/changes/HU-XXX_backend.md` (incluye tipo: API o Listener + standards)
5. `/develop-backend @HU-XXX_backend.md` → deriva:
   - `lanacion-api-developer` si el plan referencia `ln-susc-api-standards.mdc`
   - `lanacion-lstnr-developer` si el plan referencia `ln-susc-listener-standards.mdc`
6. `/opsx-verify --change "hu-XXX-descripcion"`
7. `/opsx-sync-specs --change "hu-XXX-descripcion"`
8. `/opsx-archive --change "hu-XXX-descripcion"`

**Outputs**:
- Código implementado en el monorepo (por HU).
- Verificación OpenSpec + specs sincronizadas.
- Plan técnico backend en `ai-specs/changes/...`.

### 3.4 Phase 4: Implementación individual “task-driven” (OpenSpec apply)

**Objetivo**: ejecutar tasks definidas en el change OpenSpec.

Camino recomendado:
1. `/opsx-apply "change-name"` → ejecuta tasks del plan (tasks.md) del change
2. `/opsx-verify --change "change-name"`
3. `/opsx-sync-specs --change "change-name"`
4. `/opsx-archive --change "change-name"`

**Output**:
- Implementación guiada por tasks del change y su verificación.

## 4) Diagrama único (Mermaid): comando → skill/agent → output

```mermaid
flowchart TD
  %% =========================
  %% OpenSpec: Large Project
  %% =========================
  subgraph LP[Large Project Workflow (Phase 0/1)]
    A[openspec init] --> B[/opsx-new "planning-full-project"/]
    B --> C[/opsx-ff "planning-full-project"/]
    C --> D[/opsx-apply "planning-full-project"/]
    D --> E[/opsx-sync-specs --change planning-full-project/]
    E --> F[/opsx-archive --change planning-full-project/]
    D --> O1[(Output: openspec/changes/* backlog)]
    E --> O2[(Output: openspec/specs/* synced)]
  end

  %% =========================
  %% Epic cycle
  %% =========================
  subgraph EP[Epic Cycle (Phase 2)]
    EP1[/opsx-new epic-*/] --> EP2[/opsx-ff epic-*/]
    EP2 --> EP3[/opsx-apply epic-*/]
    EP3 --> EP4[/opsx-sync-specs epic-*/]
    EP4 --> EP5[/opsx-archive epic-*/]
    EP4 --> O3[(Output: openspec/specs/* updated)]
  end

  %% =========================
  %% HU + Backend Planning/Dev
  %% =========================
  subgraph HU[HU Cycle (Phase 3)]
    H1[/opsx-new hu-*/] --> H2[/opsx-ff hu-*/]
    H2 --> P[/plan-backend-ticket HU-XXX/]
    P --> AGP[Agent: lanacion-backend-planner]
    AGP --> PL[(Output: ai-specs/changes/HU-XXX_backend.md)]
    PL --> DEV[/develop-backend @HU-XXX_backend.md/]
    DEV --> ROUTE{Plan references standards}
    ROUTE -->|ln-susc-api-standards.mdc| APIA[Agent: lanacion-api-developer]
    ROUTE -->|ln-susc-listener-standards.mdc| LSTA[Agent: lanacion-lstnr-developer]
    APIA --> CODE[(Output: code + tests + docs updates)]
    LSTA --> CODE
    CODE --> V[/opsx-verify hu-*/]
    V --> S[/opsx-sync-specs hu-*/]
    S --> AR[/opsx-archive hu-*/]
    S --> O4[(Output: openspec/specs/* merged)]
  end

  %% =========================
  %% Task-driven implementation
  %% =========================
  subgraph AP[Task-driven (Phase 4)]
    T1[/opsx-apply change-name/] --> T2[/opsx-verify change-name/]
    T2 --> T3[/opsx-sync-specs change-name/]
    T3 --> T4[/opsx-archive change-name/]
    T3 --> O5[(Output: openspec/specs/* merged)]
  end

  %% =========================
  %% Monorepo Scaffolding (parallel lane)
  %% =========================
  subgraph MONO[Monorepo Scaffolding (parallel)]
    M0[Agent: lanacion-nx-monorepo-developer] --> M1[/scaffold-api | /scaffold-listener/]
    M0 --> M2[/scaffold-lambda/]
    M1 --> SK1[Skill: scaffold-monorepo-backend-app]
    M2 --> SK2[Skill: scaffold-monorepo-lambda]
    SK1 --> VAL[Skill: validate-monorepo-integration]
    SK2 --> VAL
    VAL --> MO[(Output: apps/* + .sln + project.json + tests + cdk/*)]
  end

  %% =========================
  %% Skill-only implementation fallback
  %% =========================
  subgraph FB[Fallback (no CLI commands)]
    FB1[Skill: implement-backend-plan] --> FB2[(Output: code + tests + docs updates)]
  end
```

## 5) Notas de consistencia (para decidir “happy path”)

1. **Implementación backend tiene dos caminos**:
   - Comando: `/develop-backend @...` (camino default en `OPENSPEC-COMMANDS.md`).
   - Skill: `implement-backend-plan` (declarado como alternativa “si CLI no está disponible”).
2. **Phase 4 usa `/opsx-apply`** para ejecución task-driven del change OpenSpec, lo cual puede convivir con `/develop-backend` si se entiende que:
   - `/develop-backend` implementa el **plan técnico backend** (`ai-specs/changes/*_backend.md`),
   - `/opsx-apply` ejecuta las **tasks del change OpenSpec** (`openspec/changes/*/tasks.md`).

## 6) Outputs esperables por tipo de flujo

- **OpenSpec planning (Phase 0/1)**: backlog en `openspec/changes/*` + specs sync en `openspec/specs/*`.
- **Epic (Phase 2)**: consolidación de spec por epic en `openspec/specs/*`.
- **HU backend (Phase 3)**: plan en `ai-specs/changes/*_backend.md` + código (API/Listener) + verificación + sync specs.
- **Monorepo scaffolding (paralelo)**: `apps/*` + integración (`.sln`, `project.json`, `cdk/`, tests).

