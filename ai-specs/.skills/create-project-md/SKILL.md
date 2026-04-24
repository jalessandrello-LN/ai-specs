---
name: create-project-md
description: Generate a root project.md configuration document from existing architecture and functional documents. Use when a repository has OpenSpec workflow docs and architecture docs but does not yet have project.md.
license: MIT
compatibility: Requires repository documentation to exist before execution.
metadata:
  author: La Nacion
  version: "1.0.0"
  generatedFor: "OpenSpec project configuration"
  agent:
    - project-md-architect
  output:
    - project.md
---

Generate a root `project.md` file that acts as the project's configuration source of truth for OpenSpec planning and implementation.

## Purpose

This skill exists because multiple workflow documents assume `project.md` is present and use it as the source for:

- technology stack
- standards references
- naming conventions
- architecture patterns
- agent workflow

The file must be derived from real project documents, not written from memory.

## Mandatory Inputs

### Required architecture documents
- `_docs de soporte/architecture-1.solution-architecture.md`
- `_docs de soporte/architecture-2.webapis-architecture.md`
- `_docs de soporte/architecture-3.listener-architecture.md`

### Required functional evidence
At least one of:
- `_docs de proyecto/Funcional-spec-dd.md`
- `_docs de proyecto/requerimientos.md`

### Required naming policy documents
- `_docs de soporte/coding-naming-1.-events-and-commands-naming.md`
- `_docs de soporte/coding-naming-2-webapi-endpoint-naming.md`
- `_docs de soporte/coding-naming-3.-aws-resources-naming.md`

### Recommended workflow references
- `ORQUESTACION_OPENSPEC.md`
- `OPENSPEC-LARGE-PROJECT-WORKFLOW.md`
- `OPENSPEC-COMMANDS.md`
- `AGENTS.md`

## Agent Adoption

Adopt the role of `ai-specs/.agents/project-md-architect.md`.

Division of responsibilities:
- **This skill**: orchestrates validation, extraction, synthesis, and file generation
- **Agent**: interprets architecture and functional documents into a coherent `project.md`

## Preflight Validation

Before generating the file:

1. Confirm the three architecture documents exist.
2. Confirm at least one functional document exists.
3. Confirm the three naming policy documents exist.
4. Confirm `project.md` does not already exist, or if it exists, treat the task as an update instead of a net-new creation.
5. If any required source is missing, stop and report the missing files explicitly.

## Generation Workflow

### Step 1: Read source documents

Read the architecture documents and extract:
- overall solution shape
- API architecture
- listener architecture
- cross-cutting patterns
- internal libraries and integration patterns when documented

Read the functional documents and extract:
- business scope
- core capabilities
- domains or bounded contexts
- user-facing outcomes

Read the workflow references and extract:
- preferred OpenSpec lifecycle
- planning commands
- implementation commands
- scaffolding workflow
- fallback skill-based execution path if documented

Read the naming policy documents and extract:
- event naming pattern
- command naming pattern
- REST endpoint naming rules
- queue naming pattern
- AWS resource naming pattern

### Step 2: Build the `project.md` model

Synthesize a single configuration model with these sections:

1. `Overview`
2. `Technology Stack`
3. `Architecture Foundations`
4. `Standards Reference`
5. `Naming Conventions`
6. `Workflow`
7. `Workspace Structure`
8. `Quality Gates`
9. `Assumptions and TBDs`

### Step 3: Infer carefully

Inference rules:

- Use explicit text from docs whenever available.
- Infer only when the evidence is strong and consistent across documents.
- Mark inferred items as `Inferred from architecture/workflow docs`.
- Use `TBD` for unknown branch, queue, naming, or tooling details.
- For naming conventions, prefer the naming policy documents over workflow examples or agent text.

### Step 4: Write `project.md`

Create the file at the repository root:

```text
project.md
```

Use this template:

```markdown
# Project

## Overview
- Name: [project or initiative name]
- Scope: [business scope]
- Source Documents:
  - `_docs de soporte/architecture-1.solution-architecture.md`
  - `_docs de soporte/architecture-2.webapis-architecture.md`
  - `_docs de soporte/architecture-3.listener-architecture.md`
  - `[functional doc path(s)]`

## Technology Stack
- Backend: [runtime/framework]
- APIs: [style/template/framework]
- Listeners: [style/template/framework]
- Workspace Tooling: [Nx/OpenSpec/etc.]
- Infrastructure: [AWS/CDK/etc. if supported]

## Architecture Foundations
- Style: [microservices/event-driven/etc.]
- Patterns: [Clean Architecture, CQRS, Outbox, idempotency]
- API Architecture: [summary]
- Listener Architecture: [summary]
- Data Access: [Dapper/UoW/etc.]
- Integration: [events/SQS/etc.]

## Standards Reference
- Base: `ai-specs/specs/base-standards.mdc`
- API: `ai-specs/specs/ln-susc-api-standards.mdc`
- Listener: `ai-specs/specs/ln-susc-listener-standards.mdc`
- Frontend: [if applicable]
- Documentation: `ai-specs/specs/documentation-standards.mdc`

## Naming Conventions
- Branches: [pattern or TBD]
- Commands: [pattern or TBD]
- Events: [pattern or TBD]
- Queues: [pattern or TBD]
- Planning Prefixes: [HU-/EPIC-/MVP- or TBD]

## Workflow
- Planning: [OpenSpec planning path]
- Backend Plan Generation: [command/agent path]
- Backend Implementation: [command/agent path]
- Verification: [verify path]
- Sync/Archive: [sync/archive path]
- Monorepo Scaffolding: [scaffold path]
- Fallback Skill Path: [skills-only path if documented]

## Workspace Structure
- `openspec/`: [purpose]
- `ai-specs/`: [purpose]
- `apps/`: [purpose]
- `libs/`: [purpose]
- `cdk/`: [purpose]
- `_docs de soporte/`: [purpose]
- `_docs de proyecto/`: [purpose]

## Quality Gates
- Tests: [expectation]
- Coverage: [threshold or TBD]
- Verification: [expected command/process]
- Documentation Updates: [required docs to update]

## Assumptions and TBDs
- [List only the items that were inferred or remain unresolved]
```

## Quality Rules

The generated `project.md` must:

- be usable by `openspec-large-project-planning`
- align with the responsibilities described in `ORQUESTACION_OPENSPEC.md`
- reflect the integration expectations referenced in `OPENSPEC-LARGE-PROJECT-WORKFLOW.md`
- source naming conventions from the three `coding-naming-*` documents
- avoid undocumented claims
- preserve a clear separation between explicit facts, inferred facts, and TBDs

## Reporting Back

After generation, report:

- source documents used
- whether each major section was explicit or inferred
- unresolved TBDs
- whether the file is ready to be consumed by OpenSpec planning

## Guardrails

- Do not create `project.md` from workflow docs alone.
- Do not skip the functional documents.
- Do not skip the naming policy documents.
- Do not omit the `Workflow` section.
- Do not omit standards references if those standards exist in the repository.
- Do not hardcode conventions that are not evidenced by docs.
- If architecture docs and workflow docs conflict, prefer architecture docs for technical shape and note the conflict in `Assumptions and TBDs`.
- If naming examples in workflow docs conflict with `coding-naming-*`, prefer the naming policy documents and record the conflict.
