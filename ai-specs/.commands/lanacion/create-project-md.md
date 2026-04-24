# create-project-md

## Descripción
Genera o actualiza el archivo raíz `project.md` a partir de la documentación existente de arquitectura, requerimientos funcionales y políticas de naming.

## Sintaxis
```text
/create-project-md
```

## Referencia
Adoptar el skill `ai-specs/.skills/create-project-md/SKILL.md` y el rol analítico de `ai-specs/.agents/project-md-architect.md`.

## Fuentes obligatorias

### Arquitectura
- `_docs de soporte/architecture-1.solution-architecture.md`
- `_docs de soporte/architecture-2.webapis-architecture.md`
- `_docs de soporte/architecture-3.listener-architecture.md`

### Requerimientos funcionales
- `_docs de proyecto/Funcional-spec-dd.md`
  o
- `_docs de proyecto/requerimientos.md`

### Políticas de naming
- `_docs de soporte/coding-naming-1.-events-and-commands-naming.md`
- `_docs de soporte/coding-naming-2-webapi-endpoint-naming.md`
- `_docs de soporte/coding-naming-3.-aws-resources-naming.md`

## Proceso

1. Verificar que existan los 3 documentos de arquitectura
2. Verificar que exista al menos un documento funcional
3. Verificar que existan los 3 documentos de naming
4. Leer documentación de workflow si existe (`ORQUESTACION_OPENSPEC.md`, `OPENSPEC-LARGE-PROJECT-WORKFLOW.md`, `OPENSPEC-COMMANDS.md`, `AGENTS.md`)
5. Sintetizar el modelo de configuración del proyecto
6. Generar `project.md` en la raíz del repositorio
7. Reportar qué partes fueron explícitas, inferidas o quedaron como `TBD`

## Output

Archivo markdown en la raíz del repositorio:

```text
project.md
```

Con la siguiente estructura:

```markdown
# Project

## Overview
## Technology Stack
## Architecture Foundations
## Standards Reference
## Naming Conventions
## Workflow
## Workspace Structure
## Quality Gates
## Assumptions and TBDs
```

## Reglas de precedencia

- **Arquitectura técnica**: tomar de `architecture-1/2/3`
- **Contexto de negocio y alcance**: tomar de `Funcional-spec-dd.md` y/o `requerimientos.md`
- **Naming**: tomar siempre de `coding-naming-1/2/3`
- **Workflow**: completar desde `ORQUESTACION_OPENSPEC.md`, `OPENSPEC-LARGE-PROJECT-WORKFLOW.md`, `OPENSPEC-COMMANDS.md` y `AGENTS.md`

Si hay conflicto:
- naming docs prevalecen sobre ejemplos en workflow
- docs de arquitectura prevalecen sobre ejemplos de workflow para la forma técnica
- cualquier conflicto debe quedar documentado en `Assumptions and TBDs`

## Ejemplo de uso

```text
/create-project-md
```

## Cuándo usarlo

- Cuando el repo todavía no tiene `project.md`
- Cuando `project.md` quedó desactualizado respecto de la arquitectura o requerimientos
- Antes de `/plan-large-project` si el workflow OpenSpec necesita una fuente de verdad de configuración
