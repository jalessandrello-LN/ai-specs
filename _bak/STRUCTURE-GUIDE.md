# Estructura Completa - Guía de Referencia

## 📋 Tabla de Contenidos

1. [Ubicaciones Principales](#ubicaciones-principales)
2. [Agentes](#agentes)
3. [Skills](#skills)
4. [Comandos](#comandos)
5. [Prompts Copilot](#prompts-copilot)
6. [Estándares](#estándares)
7. [Cómo Usar](#cómo-usar)

---

## 🗂️ Ubicaciones Principales

### `.agent/` - Configuración Principal
```
.agent/
├── agents/                    # Agentes (expertos técnicos)
├── skills/                    # Skills (ejecución autónoma)
├── commands/                  # Comandos (planificación e implementación)
│   └── lanacion/             # Comandos específicos La Nación
├── specs/                     # Estándares
└── workflows/                 # Workflows de OpenSpec
```

### `.github/` - GitHub Copilot
```
.github/
├── prompts/                   # Prompts optimizados para Copilot
├── skills/                    # Skills de OpenSpec
├── specs/                     # Estándares
└── workflows/                 # Workflows de OpenSpec
```

### `ai-specs/` - Fuente Original
```
ai-specs/
├── .agents/                   # Agentes originales
├── .skills/                   # Skills originales
├── .commands/                 # Comandos originales
├── specs/                     # Estándares originales
└── changes/                   # Planes de features
```

---

## 👥 Agentes

### Ubicaciones
- **Principal**: `.agent/agents/`
- **Backup**: `ai-specs/.agents/`

### Agentes Disponibles

#### 1. lanacion-api-developer
**Especialidad**: REST APIs con .NET 6
- Clean Architecture
- CQRS con MediatR
- Dapper + Unit of Work
- Event Publishing (Outbox Pattern)
- 80%+ test coverage

**Uso**: Implementación de endpoints REST

#### 2. lanacion-lstnr-developer
**Especialidad**: SQS Listeners con .NET 6
- Event-Driven Architecture
- CQRS con MediatR
- Idempotency patterns
- SQS configuration
- 80%+ test coverage

**Uso**: Procesamiento de eventos SQS

#### 3. lanacion-backend-planner
**Especialidad**: Planificación de features backend
- Análisis de requisitos
- Generación de planes detallados
- Especificación de pasos
- Ejemplos de código

**Uso**: Crear planes de implementación

#### 4. frontend-developer
**Especialidad**: React con TypeScript
- Component patterns
- State management
- Accessibility (WCAG)
- 80%+ test coverage

**Uso**: Implementación de componentes

#### 5. backend-developer-nodejs
**Especialidad**: Node.js backend
- Express/Fastify
- TypeScript
- Testing

**Uso**: Backend con Node.js

#### 6. product-strategy-analyst
**Especialidad**: Análisis de estrategia
- Análisis de requisitos
- Especificación de features
- Validación de criterios

**Uso**: Análisis de tickets

---

## 🤖 Skills

### Ubicaciones
- **Principal**: `.agent/skills/`
- **Copilot**: `.agent/skills/implement-*-copilot/`
- **Backup**: `ai-specs/.skills/`

### Skills Disponibles

#### 1. implement-backend-plan
**Función**: Implementación autónoma de backend
- Lee plan
- Auto-selecciona agente (API o Listener)
- Implementa pasos secuencialmente
- Valida compilación
- Ejecuta tests (80%+ coverage)
- Actualiza documentación
- Pausa en errores

**Entrada**: Plan file (`@SCRUM-500_backend.md`)

#### 2. implement-frontend-plan
**Función**: Implementación autónoma de frontend
- Lee plan
- Implementa componentes
- Ejecuta tests (80%+ coverage)
- Valida accesibilidad (WCAG)
- Ejecuta linter
- Actualiza documentación
- Pausa en errores

**Entrada**: Plan file (`@SCRUM-501_frontend.md`)

#### 3. implement-backend-plan-copilot
**Función**: Versión optimizada para GitHub Copilot
- Mismo que implement-backend-plan
- Optimizado para Copilot

#### 4. implement-frontend-plan-copilot
**Función**: Versión optimizada para GitHub Copilot
- Mismo que implement-frontend-plan
- Optimizado para Copilot

#### 5. OpenSpec Skills
- openspec-new-change
- openspec-continue-change
- openspec-apply-change
- openspec-archive-change
- openspec-bulk-archive-change
- openspec-explore
- openspec-ff-change
- openspec-sync-specs
- openspec-verify-change
- openspec-onboard

---

## 📝 Comandos

### Ubicaciones
- **Principal**: `.agent/commands/`
- **Copilot**: `.agent/commands/*-copilot.md`
- **La Nación**: `.agent/commands/lanacion/`
- **Backup**: `ai-specs/.commands/`

### Comandos Disponibles

#### Planning Commands

##### plan-backend-ticket
Genera plan detallado para backend (API o Listener)
- Análisis de requisitos
- Selección de tipo (API/Listener)
- Generación de pasos
- Ejemplos de código
- Estrategia de testing

**Uso**: `plan-backend-ticket SCRUM-500`

##### plan-frontend-ticket
Genera plan detallado para frontend (React)
- Análisis de requisitos
- Diseño de componentes
- Generación de pasos
- Ejemplos de código
- Requisitos de accesibilidad

**Uso**: `plan-frontend-ticket SCRUM-501`

#### Development Commands

##### develop-backend
Implementa backend siguiendo plan
- Crea rama
- Implementa pasos
- Valida compilación
- Ejecuta tests
- Actualiza documentación

**Uso**: `develop-backend @SCRUM-500_backend.md`

##### develop-frontend
Implementa frontend siguiendo plan
- Crea rama
- Implementa componentes
- Valida compilación
- Ejecuta tests
- Valida accesibilidad

**Uso**: `develop-frontend @SCRUM-501_frontend.md`

#### Copilot-Optimized Commands

##### plan-backend-copilot
Versión optimizada para GitHub Copilot
**Uso**: `plan-backend-copilot SCRUM-500`

##### plan-frontend-copilot
Versión optimizada para GitHub Copilot
**Uso**: `plan-frontend-copilot SCRUM-501`

##### develop-backend-api-copilot
Implementar REST API (Copilot)
**Uso**: `develop-backend-api-copilot @SCRUM-500_backend.md`

##### develop-backend-listener-copilot
Implementar SQS Listener (Copilot)
**Uso**: `develop-backend-listener-copilot @SCRUM-500_backend.md`

##### develop-frontend-copilot
Implementar componente React (Copilot)
**Uso**: `develop-frontend-copilot @SCRUM-501_frontend.md`

#### La Nación Specific Commands

##### create-sqs-listener
Crear listener SQS completo
**Uso**: `create-sqs-listener [ProjectName] [EventName] [QueueName]`

##### add-event
Agregar evento a listener existente
**Uso**: `add-event [EventName] [QueueName] [HandlerLogic?]`

##### create-repository
Crear repositorio con entidad
**Uso**: `create-repository [EntityName] [DatabaseType]`

##### create-api-command
Crear comando API
**Uso**: `create-api-command [CommandName] [EntityName]`

##### create-api-query
Crear query API
**Uso**: `create-api-query [QueryName] [EntityName]`

##### configure-sqs
Configurar SQS
**Uso**: `configure-sqs [QueueName] [Environment]`

##### add-health-checks
Agregar health checks
**Uso**: `add-health-checks [ServiceName]`

##### integrate-wcf-service
Integrar servicio WCF
**Uso**: `integrate-wcf-service [ServiceName] [WsdlUrl]`

---

## 🔍 Prompts GitHub Copilot

### Ubicaciones
- **Principal**: `.github/prompts/`
- **Formato**: `.prompt.md`

### Prompts Disponibles

#### plan-backend.prompt.md
Planificar feature backend
- Análisis de requisitos
- Selección de tipo
- Generación de plan
- Ejemplos de código

#### plan-frontend.prompt.md
Planificar feature frontend
- Análisis de requisitos
- Diseño de componentes
- Generación de plan
- Ejemplos de código

#### develop-backend-api.prompt.md
Implementar REST API
- Lectura de plan
- Implementación de pasos
- Validación
- Testing

#### develop-backend-listener.prompt.md
Implementar SQS Listener
- Lectura de plan
- Implementación de pasos
- Validación
- Testing

#### develop-frontend.prompt.md
Implementar componente React
- Lectura de plan
- Implementación de pasos
- Validación
- Testing

---

## 📚 Estándares

### Ubicaciones
- **Principal**: `.agent/specs/base-standards.mdc`
- **Backup**: `ai-specs/specs/base-standards.mdc`
- **GitHub**: `.github/specs/base-standards.mdc`

### Estándares Específicos

#### Backend API
- **Archivo**: `ai-specs/specs/ln-susc-api-standards.mdc`
- **Contenido**: REST API patterns, CQRS, Event Publishing

#### Backend Listener
- **Archivo**: `ai-specs/specs/ln-susc-listener-standards.mdc`
- **Contenido**: Event processing, Idempotency, SQS patterns

#### Frontend
- **Archivo**: `ai-specs/specs/frontend-standards.mdc`
- **Contenido**: React patterns, TypeScript, Accessibility

#### Documentation
- **Archivo**: `ai-specs/specs/documentation-standards.mdc`
- **Contenido**: Documentation structure, API docs, Code docs

---

## 🚀 Cómo Usar

### Workflow Básico

#### Paso 1: Planificar
```bash
# Opción 1: Usar comando
plan-backend-ticket SCRUM-500

# Opción 2: Usar prompt Copilot
@copilot plan-backend SCRUM-500
```

**Resultado**: `ai-specs/changes/SCRUM-500_backend.md`

#### Paso 2: Implementar
```bash
# Opción 1: Usar comando
develop-backend @SCRUM-500_backend.md

# Opción 2: Usar skill
implement-backend-plan @SCRUM-500_backend.md

# Opción 3: Usar prompt Copilot
@copilot develop-backend-api @SCRUM-500_backend.md
```

#### Paso 3: Validar
- ✓ Compilación: `dotnet build`
- ✓ Tests: `dotnet test` (80%+ coverage)
- ✓ Documentación: Actualizada

#### Paso 4: Commit y Push
```bash
git add .
git commit -m "[SCRUM-500]: Implement [description]"
git push origin feature/scrum-500-[description]
```

### Seleccionar Herramienta

| Herramienta | Ubicación | Uso |
|-------------|-----------|-----|
| **Agentes** | `.agent/agents/` | Proporcionar expertise |
| **Skills** | `.agent/skills/` | Ejecución autónoma |
| **Comandos** | `.agent/commands/` | Planificación e implementación |
| **Prompts** | `.github/prompts/` | GitHub Copilot |

### Seleccionar Backend Type

| Tipo | Agente | Comando | Skill |
|------|--------|---------|-------|
| **REST API** | lanacion-api-developer | develop-backend-api-copilot | implement-backend-plan |
| **SQS Listener** | lanacion-lstnr-developer | develop-backend-listener-copilot | implement-backend-plan |
| **React** | frontend-developer | develop-frontend-copilot | implement-frontend-plan |

---

## 📊 Resumen

### Total de Archivos
- **Agentes**: 6
- **Skills**: 14
- **Comandos**: 23
- **Prompts**: 6
- **Estándares**: 5
- **Documentación**: 4

### Cobertura
- ✅ Backend API
- ✅ Backend Listener
- ✅ Frontend React
- ✅ Planning
- ✅ Implementation
- ✅ Testing
- ✅ Documentation

### Herramientas Soportadas
- ✅ Claude/Cursor
- ✅ GitHub Copilot
- ✅ Google Gemini
- ✅ Amazon Q
- ✅ Generic AI Tools

---

## 📖 Documentación Adicional

- **Setup**: `COPILOT-SETUP-SUMMARY.md`
- **Uso**: `COPILOT-USAGE-GUIDE.md`
- **Replicación**: `REPLICATION-SUMMARY.md`
- **Prompts**: `.github/prompts/README.md`
- **Comandos**: `.agent/commands/COPILOT-README.md`

---

**Última actualización**: 2024
**Estado**: ✅ Completo
