# GitHub Copilot - Archivos Creados

## Resumen

Se han creado archivos optimizados para GitHub Copilot en dos ubicaciones:

### 1. `.github/prompts/` (Prompts para GitHub Copilot)
Siguiendo el patrón de OpenSpec con archivos `.prompt.md`

### 2. `.agent/commands/` y `.agent/skills/` (Comandos y Skills)
Complementando la estructura existente de `.agent`

---

## 📁 Archivos en `.github/prompts/`

### Planning Prompts
- **`plan-backend.prompt.md`** - Planificar feature backend (API o Listener)
- **`plan-frontend.prompt.md`** - Planificar feature frontend (React)

### Development Prompts
- **`develop-backend-api.prompt.md`** - Implementar REST API
- **`develop-backend-listener.prompt.md`** - Implementar SQS Listener
- **`develop-frontend.prompt.md`** - Implementar componente React

### Documentation
- **`README.md`** - Documentación de prompts para Copilot

---

## 📁 Archivos en `.agent/commands/`

### Planning Commands
- **`plan-backend-copilot.md`** - Planificar backend
- **`plan-frontend-copilot.md`** - Planificar frontend

### Development Commands
- **`develop-backend-api-copilot.md`** - Implementar API
- **`develop-backend-listener-copilot.md`** - Implementar Listener
- **`develop-frontend-copilot.md`** - Implementar frontend

### Documentation
- **`COPILOT-README.md`** - Documentación de comandos para Copilot

---

## 📁 Archivos en `.agent/skills/`

### Backend Skills
- **`implement-backend-plan-copilot/SKILL.md`** - Skill autónomo para backend

### Frontend Skills
- **`implement-frontend-plan-copilot/SKILL.md`** - Skill autónomo para frontend

---

## 🚀 Workflow Completo para GitHub Copilot

### Paso 1: Planificar
```bash
# En .github/prompts/ o .agent/commands/
plan-backend HU-500
plan-frontend HU-501
```

### Paso 2: Implementar
```bash
# Usando prompts de .github/prompts/
develop-backend-api @HU-500_backend.md
develop-backend-listener @HU-500_backend.md
develop-frontend @HU-501_frontend.md

# O usando comandos de .agent/commands/
develop-backend-api-copilot @HU-500_backend.md
develop-backend-listener-copilot @HU-500_backend.md
develop-frontend-copilot @HU-501_frontend.md
```

### Paso 3: Validar
- ✓ Compilación
- ✓ Tests (80%+ coverage)
- ✓ Accesibilidad (frontend)
- ✓ Linting
- ✓ Documentación

### Paso 4: Commit y Push
```bash
git add .
git commit -m "[TICKET-ID]: Implement [description]"
git push origin feature/[ticket-id]-[description]
```

---

## 📊 Características

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
- State management
- Accessibility (WCAG)
- 80%+ test coverage
- Responsive design
- Error handling

---

## 🔗 Integración

### Con OpenSpec
Los nuevos prompts/comandos complementan los existentes:
- `opsx-new` - Crear cambio
- `opsx-continue` - Continuar cambio
- `opsx-apply` - Aplicar cambio

### Con Estándares
Todos siguen:
- `ai-specs/specs/base-standards.mdc`
- `.github/specs/base-standards.mdc`

---

## 📝 Notas

- Archivos optimizados para GitHub Copilot
- Siguen patrón de OpenSpec (`.prompt.md`)
- Incluyen ejemplos de código completos
- Enfatizan testing y documentación
- Requieren 80%+ code coverage
- Validan accesibilidad (frontend)
- Manejan estado y pausa inteligente en errores

---

## 📍 Ubicaciones

```
d:\template\ai-specs\
├── .github/
│   └── prompts/
│       ├── plan-backend.prompt.md
│       ├── plan-frontend.prompt.md
│       ├── develop-backend-api.prompt.md
│       ├── develop-backend-listener.prompt.md
│       ├── develop-frontend.prompt.md
│       └── README.md
│
└── .agent/
    ├── commands/
    │   ├── plan-backend-copilot.md
    │   ├── plan-frontend-copilot.md
    │   ├── develop-backend-api-copilot.md
    │   ├── develop-backend-listener-copilot.md
    │   ├── develop-frontend-copilot.md
    │   └── COPILOT-README.md
    │
    └── skills/
        ├── implement-backend-plan-copilot/
        │   └── SKILL.md
        └── implement-frontend-plan-copilot/
            └── SKILL.md
```

---

## ✅ Checklist

- [x] Prompts creados en `.github/prompts/`
- [x] Comandos creados en `.agent/commands/`
- [x] Skills creados en `.agent/skills/`
- [x] Documentación incluida
- [x] Ejemplos de código completos
- [x] Estándares referenciados
- [x] Workflow documentado
- [x] Integración con OpenSpec
