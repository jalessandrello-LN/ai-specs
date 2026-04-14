# AI Agents Configuration

This file serves as the entry point for AI-assisted development using a **Spec-Driven Development** approach. It defines the available agents, their roles, and the workflows for implementing backend features (APIs and Listeners) at La Nación.

## Core Standards

All agents follow the base development standards defined in:
- **[Base Standards](ai-specs/specs/base-standards.mdc)** - Core principles, language standards, and general guidelines

## Available Agents

### 1. Product Strategy Analyst
**File**: `ai-specs/.agents/product-strategy-analyst.md`  
**Purpose**: Enriches user stories with detailed acceptance criteria, technical considerations, and testing scenarios  
**When to use**: When a user story lacks detail or needs clarification before planning  
**Command**: `/enrich-us [TICKET-ID]`

### 2. Backend Planner (La Nación)
**File**: `ai-specs/.agents/lanacion-backend-planner.md`  
**Purpose**: Creates detailed implementation plans for backend features (APIs or Listeners)  
**Technology**: .NET 6, Clean Architecture, CQRS, Event-Driven  
**Standards**: 
- APIs: `ai-specs/specs/ln-susc-api-standards.mdc`
- Listeners: `ai-specs/specs/ln-susc-listener-standards.mdc`

**When to use**: After user story is ready, to generate step-by-step implementation plan  
**Command**: `/plan-backend-ticket [TICKET-ID]`

**Output**: Generates `ai-specs/changes/[TICKET-ID]_backend.md` with complete implementation plan

### 3. API Developer (La Nación)
**File**: `ai-specs/.agents/lanacion-api-developer.md`  
**Purpose**: Implements REST APIs using LaNacion.Core.Templates.Web.Api.Minimal  
**Technology**: .NET 6, ASP.NET Core Minimal APIs, MediatR, Dapper  
**Architecture**: Clean Architecture + CQRS + Event Publishing (Outbox Pattern)  
**Standards**: `ai-specs/specs/ln-susc-api-standards.mdc`

**When to use**: To implement HTTP REST endpoints that modify or query state  
**Command**: `/develop-backend @[TICKET-ID]_backend.md` (when plan references API standards)

**Key Patterns**:
- Commands (write operations) with FluentValidation
- Queries (read operations)
- Event publishing inside transactions
- REST conventions (plural nouns, proper HTTP methods)

### 4. Listener Developer (La Nación)
**File**: `ai-specs/.agents/lanacion-lstnr-developer.md`  
**Purpose**: Implements SQS message listeners using ln-SQSlstnr template  
**Technology**: .NET 6, IHostedService, MediatR, Dapper, AWS SQS  
**Architecture**: Clean Architecture + CQRS + Event Processing + Idempotency  
**Standards**: `ai-specs/specs/ln-susc-listener-standards.mdc`

**When to use**: To implement event-driven message processors that consume from SQS queues  
**Command**: `/develop-backend @[TICKET-ID]_backend.md` (when plan references Listener standards)

**Key Patterns**:
- Event processors (IRequest<ProcessResult>)
- Idempotency with MensajesRecibidos table
- SQS queue consumption
- Transaction management with Unit of Work

### 5. Frontend Developer
**File**: `ai-specs/.agents/frontend-developer.md`  
**Purpose**: Implements React components and frontend features  
**Technology**: React, TypeScript  
**Standards**: `ai-specs/specs/frontend-standards.mdc`

**When to use**: To implement UI components and frontend logic  
**Commands**: 
- `/plan-frontend-ticket [TICKET-ID]`
- `/develop-frontend @[TICKET-ID]_frontend.md`

### 6. Nx Monorepo Developer
**File**: `ai-specs/.agents/lanacion-nx-monorepo-developer.md`  
**Purpose**: Creates and integrates new monorepo projects for Minimal APIs, SQS listeners, and Lambdas using the Nx + .NET template  
**Technology**: Nx, .NET 6/8, AWS CDK, Docker, Azure Artifacts  
**Architecture**: Hybrid monorepo (Nx orchestration + .NET build + co-located CDK)  
**References**:
- `ai-specs/scr/template-nx-dotnet-desde-cero.md`
- `ai-specs/scr/arq-monorepo.md`
- `ai-specs/specs/ln-susc-api-standards.mdc`
- `ai-specs/specs/ln-susc-listener-standards.mdc`

**When to use**: To scaffold a new API, listener, or Lambda from scratch inside the monorepo and leave it integrated with `.sln`, `project.json`, tests, and `cdk/`  
**Primary entrypoints**:
- `npm run generate:template` for APIs and listeners
- `npm run generate:lambda` for Lambdas

## Spec-Driven Development Workflow

### Backend Development Flow

```
┌─────────────────────────────────────────────────────────────┐
│ Step 1: Enrich User Story (Optional)                        │
│ Command: /enrich-us [TICKET-ID]                             │
│ Agent: product-strategy-analyst                             │
│ Output: Enhanced user story with acceptance criteria        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 2: Generate Implementation Plan                        │
│ Command: /plan-backend-ticket [TICKET-ID]                   │
│ Agent: lanacion-backend-planner                             │
│ Output: ai-specs/changes/[TICKET-ID]_backend.md             │
│                                                              │
│ Planner automatically detects:                              │
│ • API → References ln-susc-api-standards.mdc                │
│ • Listener → References ln-susc-listener-standards.mdc      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 3: Implement Following Plan                            │
│ Command: /develop-backend @[TICKET-ID]_backend.md           │
│                                                              │
│ Agent Selection (based on plan references):                 │
│ • If plan references ln-susc-api-standards.mdc              │
│   → Use lanacion-api-developer                              │
│ • If plan references ln-susc-listener-standards.mdc         │
│   → Use lanacion-lstnr-developer                            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Nota: si la tarea requiere scaffolding o integración del   │
│ workspace (por ejemplo: dar de alta una nueva API, Listener │
│ o Lambda dentro del monorepo), el flujo debe enrutar       │
│ primero al agente `lanacion-nx-monorepo-developer`. Ese    │
│ agente ejecuta el scaffolding/integración (p. ej.          │
│ `scaffold-monorepo-backend-app`) y usa el generador del    │
│ monorepo (`npm run generate:template`) como entrypoint     │
│ para crear e integrar proyectos en la solución monorepo.    │
└─────────────────────────────────────────────────────────────┘
```

### When to Use API vs Listener

#### Use API Developer When:
- Creating/modifying HTTP REST endpoints
- Implementing CRUD operations
- Exposing data to external clients
- Synchronous request/response patterns
- Publishing domain events (Outbox Pattern)

**Example**: Create subscription, Update customer, Get order details

#### Use Listener Developer When:
- Processing messages from SQS queues
- Reacting to domain events from other services
- Asynchronous event-driven processing
- Background data synchronization
- Idempotent message handling

**Example**: Process subscription-created event, Handle payment-completed event

## Architecture Alignment

All backend agents follow the architecture defined in:
- **[ARQUITECTURA.md](ai-specs/_docs de soporte/ARQUITECTURA.md)** - Complete architecture documentation

### Key Architectural Principles:

1. **Clean Architecture**: Domain → Application → Infrastructure → Presentation
2. **CQRS**: Commands (write) and Queries (read) separation with MediatR
3. **Event-Driven**: 
   - APIs publish events using Outbox Pattern
   - Listeners consume events from SQS
4. **Unit of Work**: Transactional consistency with Dapper
5. **Dependency Injection**: All dependencies injected via DI container

### Project Structure (Both API and Listener):

```
[Project].Domain/              # Entities, Value Objects
[Project].Domain.Events/       # Domain events (for Listeners)
[Project].Application/         # Commands, Queries, Handlers
[Project].Application.Interfaces/  # Repository interfaces
[Project].Repositories.SQL/    # Dapper implementations
[Project].Api/                 # Minimal API endpoints (API only)
[Project]/Workers/             # Hosted services (Listener only)
```

## Naming Conventions

### Commands (APIs)
Pattern: `cmd-{verb}-{entity}`
- Example: `cmd-create-subscription`, `cmd-update-customer`

### Events (Both)
Pattern: `evt-{squad}-{entity}-{verb-past}`
- Example: `evt-susc-suscripcion-creada`, `evt-maxi-descuento-aplicado`

### Queues (Listeners)
Pattern: `{product}-{env}-sqs-{event}`
- Example: `suscripciones-prod-sqs-ventas-alta`

### Branches
- API: `feature/[TICKET-ID]-api`
- Listener: `feature/[TICKET-ID]-listener`

## Quick Reference

### Complete Backend Implementation (API Example)

```bash
# 1. Enrich user story (optional)
/enrich-us HU-123

# 2. Generate plan
/plan-backend-ticket HU-123
# → Creates ai-specs/changes/HU-123_backend.md
# → Plan references ln-susc-api-standards.mdc

# 3. Implement
/develop-backend @HU-123_backend.md
# → Uses lanacion-api-developer agent
# → Creates feature/HU-123-api branch
# → Implements REST endpoints with CQRS
# → Publishes events with Outbox Pattern
# → Writes comprehensive tests
# → Updates documentation
```

### Complete Backend Implementation (Listener Example)

```bash
# 1. Enrich user story (optional)
/enrich-us HU-456

# 2. Generate plan
/plan-backend-ticket HU-456
# → Creates ai-specs/changes/HU-456_backend.md
# → Plan references ln-susc-listener-standards.mdc

# 3. Implement
/develop-backend @HU-456_backend.md
# → Uses lanacion-lstnr-developer agent
# → Creates feature/HU-456-listener branch
# → Implements SQS event processor
# → Adds idempotency handling
# → Writes comprehensive tests
# → Updates documentation
```

## Specialized Commands

For advanced scenarios, use specialized commands in `ai-specs/.commands/lanacion/`:

- `/create-sqs-listener` - Generate complete SQS listener
- `/add-event` - Add new event handler to existing listener
- `/create-repository` - Generate repository with entity
- `/configure-sqs` - Set up SQS configuration
- `/create-api-command` - Create new API command
- `/create-api-query` - Create new API query
- `/integrate-wcf-service` - Integrate legacy WCF service

See `ai-specs/.commands/lanacion/README.md` for detailed documentation.

## Standards Reference

- **Base Standards**: `ai-specs/specs/base-standards.mdc`
- **API Standards**: `ai-specs/specs/ln-susc-api-standards.mdc`
- **Listener Standards**: `ai-specs/specs/ln-susc-listener-standards.mdc`
- **Frontend Standards**: `ai-specs/specs/frontend-standards.mdc`
- **Documentation Standards**: `ai-specs/specs/documentation-standards.mdc`
- **Architecture**: `ai-specs/_docs de soporte/ARQUITECTURA.md`

---

**This configuration enables autonomous, consistent, and high-quality backend development following La Nación's architectural standards.**
