# GitHub Copilot - Guía de Uso

## Cómo GitHub Copilot Encuentra los Archivos

GitHub Copilot busca automáticamente en estas ubicaciones:

### 1. Prompts (`.prompt.md`)
```
.github/prompts/*.prompt.md
.agent/commands/*.md
```

### 2. Skills (SKILL.md)
```
.github/skills/*/SKILL.md
.agent/skills/*/SKILL.md
```

### 3. Agentes (`.md`)
```
.github/.agents/*.md
.agent/agents/*.md
```

---

## 🎯 Cómo Usar

### Opción 1: Usar Prompts de `.github/prompts/`

GitHub Copilot detectará automáticamente los prompts `.prompt.md`:

```
@copilot plan-backend HU-500
@copilot develop-backend-api @HU-500_backend.md
@copilot develop-frontend @HU-501_frontend.md
```

### Opción 2: Usar Comandos de `.agent/commands/`

GitHub Copilot también puede usar los comandos de `.agent`:

```
@copilot plan-backend-copilot HU-500
@copilot develop-backend-api-copilot @HU-500_backend.md
@copilot develop-frontend-copilot @HU-501_frontend.md
```

### Opción 3: Usar Skills Autónomos

Para implementación completamente autónoma:

```
@copilot implement-backend-plan-copilot @HU-500_backend.md
@copilot implement-frontend-plan-copilot @HU-501_frontend.md
```

---

## 📋 Workflow Recomendado

### Paso 1: Planificar la Feature

```
@copilot plan-backend HU-500
```

**Resultado**: Genera `ai-specs/changes/HU-500_backend.md` con:
- Descripción detallada
- Pasos de implementación
- Ejemplos de código
- Estrategia de testing

### Paso 2: Implementar Siguiendo el Plan

```
@copilot develop-backend-api @HU-500_backend.md
```

**Resultado**: Implementa automáticamente:
- Domain Layer
- Application Layer
- Infrastructure Layer
- Presentation Layer
- DI Registration
- Configuration
- Unit Tests (80%+ coverage)
- Documentation

### Paso 3: Validar

GitHub Copilot automáticamente:
- ✓ Verifica compilación (`dotnet build`)
- ✓ Ejecuta tests (`dotnet test`)
- ✓ Valida cobertura (≥ 80%)
- ✓ Valida accesibilidad (frontend)
- ✓ Ejecuta linter
- ✓ Actualiza documentación

### Paso 4: Commit y Push

```bash
git add .
git commit -m "[HU-500]: Implement [description]"
git push origin feature/HU-500-[description]
```

---

## 🔧 Configuración de GitHub Copilot

### 1. Asegurar que Copilot Detecta los Archivos

Los archivos deben estar en:
- `.github/prompts/` (para prompts)
- `.agent/commands/` (para comandos)
- `.agent/skills/` (para skills)

### 2. Usar Rutas Relativas

Cuando referenciar archivos:
```
@HU-500_backend.md
ai-specs/changes/HU-500_backend.md
```

### 3. Mencionar Contexto

Para mejor contexto, menciona:
```
@copilot plan-backend HU-500
# Copilot buscará el ticket HU-500 en el contexto
```

---

## 📚 Ejemplos de Uso

### Ejemplo 1: Crear API REST

```
@copilot plan-backend HU-500

# Copilot genera el plan

@copilot develop-backend-api @HU-500_backend.md

# Copilot implementa automáticamente
```

### Ejemplo 2: Crear SQS Listener

```
@copilot plan-backend HU-501

# Copilot genera el plan

@copilot develop-backend-listener @HU-501_backend.md

# Copilot implementa automáticamente
```

### Ejemplo 3: Crear Componente React

```
@copilot plan-frontend HU-502

# Copilot genera el plan

@copilot develop-frontend @HU-502_frontend.md

# Copilot implementa automáticamente
```

---

## 🎓 Estándares Aplicados

Todos los prompts/comandos siguen:

### Backend API
- Clean Architecture
- CQRS con MediatR
- Dapper + Unit of Work
- Event Publishing (Outbox Pattern)
- 80%+ test coverage

### Backend Listener
- Event-Driven Architecture
- CQRS con MediatR
- Dapper + Unit of Work
- Idempotency patterns
- 80%+ test coverage

### Frontend
- React + TypeScript
- State management
- Accessibility (WCAG)
- 80%+ test coverage
- Responsive design

---

## ⚙️ Configuración Recomendada

### En `.copilot/config.json` (si existe)

```json
{
  "prompts": {
    "paths": [
      ".github/prompts",
      ".agent/commands"
    ]
  },
  "skills": {
    "paths": [
      ".github/skills",
      ".agent/skills"
    ]
  },
  "standards": {
    "coverage": 80,
    "accessibility": true,
    "linting": true
  }
}
```

---

## 🚨 Troubleshooting

### Copilot no encuentra los prompts

1. Verificar que los archivos existen en:
   - `.github/prompts/*.prompt.md`
   - `.agent/commands/*.md`

2. Verificar que los archivos tienen el formato correcto:
   ```yaml
   ---
   description: [descripción]
   ---
   ```

### Copilot no ejecuta los tests

1. Verificar que el proyecto tiene tests configurados
2. Verificar que `dotnet test` funciona manualmente
3. Verificar que la cobertura es ≥ 80%

### Copilot no valida accesibilidad

1. Verificar que el proyecto tiene herramientas de a11y
2. Verificar que `npm run lint:a11y` funciona manualmente

---

## 📖 Documentación Adicional

- `.github/prompts/README.md` - Documentación de prompts
- `.agent/commands/COPILOT-README.md` - Documentación de comandos
- `ai-specs/specs/base-standards.mdc` - Estándares base
- `COPILOT-SETUP-SUMMARY.md` - Resumen de setup

---

## ✅ Checklist de Uso

- [ ] Archivos creados en `.github/prompts/`
- [ ] Archivos creados en `.agent/commands/`
- [ ] Archivos creados en `.agent/skills/`
- [ ] GitHub Copilot detecta los archivos
- [ ] Primer plan generado exitosamente
- [ ] Primera implementación completada
- [ ] Tests ejecutados y validados
- [ ] Documentación actualizada
- [ ] Cambios commiteados y pusheados

---

## 🎯 Próximos Pasos

1. **Probar con GitHub Copilot**:
   ```
   @copilot plan-backend HU-500
   ```

2. **Generar plan**:
   - Copilot crea `ai-specs/changes/HU-500_backend.md`

3. **Implementar**:
   ```
   @copilot develop-backend-api @HU-500_backend.md
   ```

4. **Validar**:
   - Compilación ✓
   - Tests ✓
   - Cobertura ✓
   - Documentación ✓

5. **Commit y Push**:
   ```bash
   git add .
   git commit -m "[HU-500]: Implement [description]"
   git push origin feature/HU-500-[description]
   ```

---

## 📞 Soporte

Para problemas o preguntas:
1. Revisar la documentación en `.github/prompts/README.md`
2. Revisar la documentación en `.agent/commands/COPILOT-README.md`
3. Revisar los estándares en `ai-specs/specs/base-standards.mdc`
4. Consultar ejemplos en `ai-specs/changes/`
