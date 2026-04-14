# GitHub Copilot Commands & Skills

Comandos y skills optimizados para GitHub Copilot en la carpeta `.agent`.

## Nuevos Comandos para Copilot

### Planning Commands

#### `plan-backend-copilot.md`
Genera un plan detallado para implementar una feature backend (API o Listener).

**Uso**:
```
plan-backend HU-500
```

**Genera**: `ai-specs/changes/HU-500_backend.md` con:
- Descripción de la feature
- Pasos de implementación detallados
- Ejemplos de código completos
- Estrategia de testing
- Documentación necesaria

#### `plan-frontend-copilot.md`
Genera un plan detallado para implementar una feature frontend (React component).

**Uso**:
```
plan-frontend HU-501
```

**Genera**: `ai-specs/changes/HU-501_frontend.md` con:
- Descripción de la feature
- Estructura de componentes
- Pasos de implementación detallados
- Ejemplos de código completos
- Estrategia de testing
- Requisitos de accesibilidad

### Development Commands

#### `develop-backend-api-copilot.md`
Implementa una REST API siguiendo el plan generado.

**Uso**:
```
develop-backend-api @HU-500_backend.md
```

**Implementa**:
1. Domain Layer (entidades)
2. Application Layer (CQRS)
3. Infrastructure Layer (repositorios)
4. Presentation Layer (endpoints)
5. DI Registration
6. Configuration
7. Unit Tests (80%+ coverage)
8. Documentation

#### `develop-backend-listener-copilot.md`
Implementa un SQS Listener siguiendo el plan generado.

**Uso**:
```
develop-backend-listener @HU-500_backend.md
```

**Implementa**:
1. Domain Layer (eventos)
2. Application Layer (procesadores)
3. Infrastructure Layer (repositorios)
4. SQS Configuration
5. DI Registration
6. Configuration
7. Unit Tests (80%+ coverage, incluyendo idempotencia)
8. Documentation

#### `develop-frontend-copilot.md`
Implementa un componente React siguiendo el plan generado.

**Uso**:
```
develop-frontend @HU-501_frontend.md
```

**Implementa**:
1. Component Setup
2. Props y Types
3. State Management
4. Event Handlers
5. Accessibility
6. Styling
7. Unit Tests (80%+ coverage)
8. Documentation

## Nuevos Skills para Copilot

### `implement-backend-plan-copilot/SKILL.md`
Skill autónomo para implementación backend.

**Características**:
- Auto-detecta tipo de backend (API o Listener)
- Implementa todos los pasos en loop
- Valida compilación automáticamente
- Ejecuta tests y valida 80%+ coverage
- Actualiza documentación automáticamente
- Pausa inteligentemente en errores

### `implement-frontend-plan-copilot/SKILL.md`
Skill autónomo para implementación frontend.

**Características**:
- Implementa componentes con state management
- Ejecuta tests y valida 80%+ coverage
- Valida accesibilidad (WCAG)
- Ejecuta linter automáticamente
- Actualiza documentación automáticamente
- Pausa inteligentemente en errores

## Workflow Completo

### Paso 1: Planificar

```bash
plan-backend HU-500
# o
plan-frontend HU-501
```

Genera un plan detallado en `ai-specs/changes/`

### Paso 2: Implementar

```bash
develop-backend-api @HU-500_backend.md
# o
develop-backend-listener @HU-500_backend.md
# o
develop-frontend @HU-501_frontend.md
```

Implementa automáticamente siguiendo el plan.

### Paso 3: Validar

El comando automáticamente:
- ✓ Verifica compilación
- ✓ Ejecuta tests
- ✓ Valida cobertura (80%+)
- ✓ Valida accesibilidad (frontend)
- ✓ Ejecuta linter
- ✓ Actualiza documentación

### Paso 4: Commit y Push

```bash
git add .
git commit -m "[TICKET-ID]: Implement [description]"
git push origin feature/[ticket-id]-[description]
```

## Estándares de Referencia

Todos los comandos y skills siguen los estándares definidos en:
- `ai-specs/specs/base-standards.mdc`

## Características

### Backend API
- Clean Architecture
- CQRS con MediatR
- Dapper + Unit of Work
- Event Publishing (Outbox Pattern)
- 80%+ test coverage
- REST naming conventions

### Backend Listener
- Event-Driven Architecture
- CQRS con MediatR
- Dapper + Unit of Work
- Idempotency patterns
- 80%+ test coverage
- SQS configuration

### Frontend
- React + TypeScript
- State management (useState, useContext, etc.)
- Accessibility (WCAG)
- 80%+ test coverage
- Responsive design
- Error handling

## Integración con OpenSpec

Estos comandos y skills complementan los existentes de OpenSpec:
- `opsx/new.md` - Crear nuevo cambio
- `opsx/continue.md` - Continuar cambio
- `opsx/apply.md` - Aplicar cambio
- etc.

## Notas

- Los comandos están optimizados para GitHub Copilot
- Los skills son autónomos y manejan estado
- Incluyen ejemplos de código completos
- Enfatizan testing y documentación
- Requieren 80%+ code coverage
- Validan accesibilidad (frontend)
- Siguen el patrón de OpenSpec
