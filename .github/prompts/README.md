# GitHub Copilot Prompts

Prompts optimizados para GitHub Copilot siguiendo el patrón de OpenSpec.

## Prompts Disponibles

### Planning Prompts

#### `plan-backend.prompt.md`
Genera un plan detallado para implementar una feature backend (API o Listener).

**Uso**:
```
plan-backend SCRUM-500
```

**Genera**: `ai-specs/changes/SCRUM-500_backend.md` con:
- Descripción de la feature
- Pasos de implementación detallados
- Ejemplos de código completos
- Estrategia de testing
- Documentación necesaria

#### `plan-frontend.prompt.md`
Genera un plan detallado para implementar una feature frontend (React component).

**Uso**:
```
plan-frontend SCRUM-501
```

**Genera**: `ai-specs/changes/SCRUM-501_frontend.md` con:
- Descripción de la feature
- Estructura de componentes
- Pasos de implementación detallados
- Ejemplos de código completos
- Estrategia de testing
- Requisitos de accesibilidad

### Development Prompts

#### `develop-backend-api.prompt.md`
Implementa una REST API siguiendo el plan generado.

**Uso**:
```
develop-backend-api @SCRUM-500_backend.md
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

#### `develop-backend-listener.prompt.md`
Implementa un SQS Listener siguiendo el plan generado.

**Uso**:
```
develop-backend-listener @SCRUM-500_backend.md
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

#### `develop-frontend.prompt.md`
Implementa un componente React siguiendo el plan generado.

**Uso**:
```
develop-frontend @SCRUM-501_frontend.md
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

## Workflow Completo

### Paso 1: Planificar

```bash
plan-backend SCRUM-500
# o
plan-frontend SCRUM-501
```

Genera un plan detallado en `ai-specs/changes/`

### Paso 2: Implementar

```bash
develop-backend-api @SCRUM-500_backend.md
# o
develop-backend-listener @SCRUM-500_backend.md
# o
develop-frontend @SCRUM-501_frontend.md
```

Implementa automáticamente siguiendo el plan.

### Paso 3: Validar

El prompt automáticamente:
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

Todos los prompts siguen los estándares definidos en:
- `.github/specs/base-standards.mdc`

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

Estos prompts complementan los prompts de OpenSpec existentes:
- `opsx-new.prompt.md` - Crear nuevo cambio
- `opsx-continue.prompt.md` - Continuar cambio
- `opsx-apply.prompt.md` - Aplicar cambio
- etc.

## Notas

- Los prompts están optimizados para GitHub Copilot
- Siguen el patrón de OpenSpec (archivos `.prompt.md`)
- Incluyen ejemplos de código completos
- Enfatizan testing y documentación
- Requieren 80%+ code coverage
- Validan accesibilidad (frontend)
