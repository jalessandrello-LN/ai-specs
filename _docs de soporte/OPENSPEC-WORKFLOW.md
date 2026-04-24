# OpenSpec Workflow Guide for LaNacion Subscriptions

**Document Version**: 1.0.0
**Last Updated**: April 16, 2026
**Project**: LaNacion Subscriptions Module Reengineering

---

## Table of Contents

1. [Overview](#1-overview)
2. [Document Hierarchy](#2-document-hierarchy)
3. [Workflow Overview](#3-workflow-overview)
4. [From Vision to Implementation](#4-from-vision-to-implementation)
5. [Artifact Templates](#5-artifact-templates)
6. [Command Reference](#6-command-reference)
7. [Examples](#7-examples)
8. [Integration with Existing Docs](#8-integration-with-existing-docs)

---

## 1. Overview

This guide describes the **OpenSpec-based workflow** for transforming high-level business requirements into implemented backend features for the LaNacion Subscriptions system.

### Goals

- **Traceability**: Every line of code traces back to a business requirement
- **Consistency**: All changes follow the same structured workflow
- **Completeness**: Nothing is forgotten between conception and delivery

### Key Documents

| Document | Purpose | Location |
|----------|---------|----------|
| `project.md` | Project configuration and agent setup | Root |
| `Funcional-spec-dd.md` | Functional vision and domain model | `_docs de proyecto/` |
| `ARQUITECTURA.md` | Technical architecture | `_docs de soporte/` |
| `data-model.md` | Database schema reference | `ai-specs/specs/` |

---

## 2. Document Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                     STRATEGIC LAYER                             │
│  project.md (Configuration & Vision)                            │
│  ├── Business Drivers                                          │
│  ├── Architecture Foundations                                   │
│  └── Agent Configuration                                        │
└────────────────────────────┬────────────────────────────────────┘
                             │ drives
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                                │
│  Funcional-spec-dd.md (Functional Specification)                │
│  ├── Domain Definition                                         │
│  ├── Business Rules                                            │
│  ├── Use Cases                                                │
│  └── Integration Boundaries                                     │
└────────────────────────────┬────────────────────────────────────┘
                             │ inspires
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     PLANNING LAYER                              │
│  OpenSpec Changes (Epics → MVPs → HUs)                        │
│  ├── Epic: subscription-management                             │
│  │   ├── MVP: mvp-subscription-lifecycle                      │
│  │   │   ├── HU-001: create-subscription                      │
│  │   │   └── HU-002: cancel-subscription                      │
│  │   └── MVP: mvp-bundle-management                            │
│  │       ├── HU-003: create-bundle                            │
│  │       └── HU-004: update-bundle-composition                │
└────────────────────────────┬────────────────────────────────────┘
                             │ enables
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     IMPLEMENTATION LAYER                        │
│  ai-specs/changes/ (Backend Implementation Plans)              │
│  ├── HU-001_backend.md (API Plan)                             │
│  └── HU-002_backend.md (Listener Plan)                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Workflow Overview

### 3.1 High-Level Flow

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         BACKLOG CREATION PHASE                             │
│                                                                             │
│  Business Requirement ──► Epic ──► MVP ──► User Stories (HUs)            │
│                                                                             │
│  Command: /openspec new change "epic-name"                                 │
│  Schema: epic-mvp-hu                                                        │
└────────────────────────────────┬───────────────────────────────────────────┘
                                 │
                                 ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                       SPECIFICATION PHASE                                  │
│                                                                             │
│  User Story ──► Proposal ──► Design ──► Task List                         │
│                                                                             │
│  Artifact Sequence:                                                          │
│  1. proposal.md (What & Why)                                              │
│  2. design.md (How)                                                        │
│  3. tasks.md (Checklist)                                                   │
└────────────────────────────────┬───────────────────────────────────────────┘
                                 │
                                 ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                      IMPLEMENTATION PHASE                                  │
│                                                                             │
│  Tasks ──► Backend Plan ──► Code ──► Tests ──► Docs                     │
│                                                                             │
│  Command: /develop-backend @HU-XXX_backend.md                              │
└────────────────────────────────┬───────────────────────────────────────────┘
                                 │
                                 ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                       VERIFICATION PHASE                                   │
│                                                                             │
│  Implementation ──► Verify ──► Archive                                     │
│                                                                             │
│  Commands:                                                                 │
│  - /openspec verify change "epic-name"                                    │
│  - /openspec archive change "epic-name"                                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Detailed Artifact Flow

```
Feature Request
      │
      ▼
┌─────────────────┐
│  PROPOSAL       │  "What do we want? Why?"
│  (proposal.md)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  DESIGN         │  "How will it work?"
│  (design.md)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  TASKS         │  "What needs to be done?"
│  (tasks.md)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  BACKEND PLAN   │  "Implementation guide"
│  (_backend.md)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  CODE          │  "Actual implementation"
│  + TESTS       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  VERIFICATION   │  "Did we build it right?"
│  (openspec     │
│   verify)       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  ARCHIVE       │  "Done, move to completed"
│  (openspec     │
│   archive)      │
└─────────────────┘
```

---

## 4. From Vision to Implementation

### Step 1: Create Epic from Business Requirement

When a new business driver emerges from `Funcional-spec-dd.md`:

```bash
# Create an epic for subscription management capabilities
/openspec new change "subscription-management"

# Or with explicit schema
/openspec new change "subscription-management" --schema epic-mvp-hu
```

### Step 2: Define MVPs within Epic

Inside the epic, create MVPs that group related functionality:

```bash
# Create MVP for basic subscription lifecycle
/openspec new change "subscription-lifecycle" --schema mvp

# Attach to parent epic
/openspec relate mvp:subscription-lifecycle epic:subscription-management
```

### Step 3: Create User Stories (HUs) from Use Cases

Each use case from `Funcional-spec-dd.md` becomes a HU:

```bash
# Create HU for subscription creation
/openspec new change "create-subscription" --schema hu

# Create HU for subscription cancellation
/openspec new change "cancel-subscription" --schema hu
```

### Step 4: Generate Backend Implementation Plan

Convert HU to technical plan:

```bash
# Generate backend implementation plan from HU
/plan-backend-ticket HU-001
```

---

## 5. Artifact Templates

### 5.1 Proposal Artifact

```markdown
# Proposal: [Feature Name]

## Summary
Brief description of what this change accomplishes.

## Problem Statement
What business problem does this solve?

## Goals
- Primary goal
- Secondary goals

## Non-Goals
What this change does NOT address.

## Background
Context from `Funcional-spec-dd.md` and `project.md`.

## Success Criteria
How do we know this succeeded?

## Risks
- Risk 1
- Risk 2

## Alternatives Considered
Other approaches that were rejected.

## Dependencies
What must be in place first?
```

### 5.2 Design Artifact

```markdown
# Design: [Feature Name]

## Architecture
How does this fit into the overall system?

## Data Model Changes
Updates to `data-model.md` entities.

## API Design
For API features:
- Endpoint: POST /api/v1/...
- Request/Response schemas

## Event Design
For event-driven features:
- Event: evt-{squad}-{entity}-{verb-past}
- Queue: {product}-{env}-sqs-{event}

## Security
Authentication, authorization, validation.

## Error Handling
How errors are communicated.

## Migration Strategy
Database changes if any.
```

### 5.3 Tasks Artifact

```markdown
# Tasks: [Feature Name]

## Implementation Tasks

- [ ] Create feature branch: `feature/[TICKET-ID]-[api|listener]`
- [ ] Implement domain entity
- [ ] Implement command/query or event
- [ ] Implement handler/processor
- [ ] Implement repository
- [ ] Implement endpoint/worker
- [ ] Add unit tests
- [ ] Update documentation
- [ ] Verify implementation

## Verification Tasks

- [ ] All tests pass
- [ ] Code coverage >= 80%
- [ ] No compilation warnings
- [ ] Documentation complete
```

### 5.4 Backend Plan Artifact

See `ai-specs/changes/[TICKET-ID]_backend.md` template in `lanacion-backend-planner.md`.

---

## 6. Command Reference

### 6.1 OpenSpec Core Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `/openspec new change` | Create new change with schema | `/openspec new change "create-subscription" --schema hu` |
| `/openspec status` | Show change artifact status | `/openspec status --change "create-subscription"` |
| `/openspec instructions` | Get template for next artifact | `/openspec instructions proposal --change "create-subscription"` |
| `/openspec continue` | Create next artifact in sequence | `/openspec continue proposal --change "create-subscription"` |
| `/openspec verify` | Verify implementation matches spec | `/openspec verify change "create-subscription"` |
| `/openspec archive` | Archive completed change | `/openspec archive change "create-subscription"` |
| `/openspec sync-specs` | Sync delta specs to main | `/openspec sync-specs --change "create-subscription"` |

### 6.2 LaNacion Backend Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `/enrich-us` | Enrich user story with acceptance criteria | `/enrich-us HU-001` |
| `/plan-backend-ticket` | Generate backend implementation plan | `/plan-backend-ticket HU-001` |
| `/develop-backend` | Implement from backend plan | `/develop-backend @HU-001_backend.md` |

### 6.3 OpenSpec Skill Commands (Alternative)

For AI agents that support skills:

| Skill | Purpose |
|-------|---------|
| `openspec-new-change` | Start new change |
| `openspec-continue-change` | Continue with next artifact |
| `openspec-apply-change` | Apply tasks from artifact |
| `openspec-verify-change` | Verify implementation |
| `openspec-archive-change` | Archive completed change |
| `openspec-explore` | Explore requirements |
| `openspec-ff-change` | Fast-forward through artifacts |
| `openspec-sync-specs` | Sync specs to main |
| `implement-backend-plan` | Implement backend from plan |

---

## 7. Examples

### Example 1: Complete Epic Flow

```bash
# 1. Create epic for bundle management
/openspec new change "bundle-management" --schema epic

# 2. Inside epic, add proposal
# File: openspec/changes/bundle-management/001_proposal.md
/openspec continue proposal --change "bundle-management"

# 3. Add design
# File: openspec/changes/bundle-management/002_design.md
/openspec continue design --change "bundle-management"

# 4. Add MVP breakdown
# File: openspec/changes/bundle-management/003_mvp.md
/openspec continue mvp --change "bundle-management"

# 5. List available schemas
openspec schemas --json

# 6. View current status
/openspec status --change "bundle-management"
```

### Example 2: HU to Implementation

```bash
# 1. Create HU for subscription creation
/openspec new change "subscription-creation" --schema hu

# 2. Generate proposal
/openspec continue proposal --change "subscription-creation"

# 3. Generate design
/openspec continue design --change "subscription-creation"

# 4. Generate tasks
/openspec continue tasks --change "subscription-creation"

# 5. Plan backend implementation
/plan-backend-ticket HU-001
# Output: ai-specs/changes/HU-001_backend.md

# 6. Implement
/develop-backend @HU-001_backend.md

# 7. Verify
/openspec verify change "subscription-creation"

# 8. Archive
/openspec archive change "subscription-creation"
```

### Example 3: Parallel HU Development

```bash
# Sprint planning: create multiple HUs
/openspec new change "subscription-pause" --schema hu &
/openspec new change "subscription-renew" --schema hu &
/openspec new change "subscription-upgrade" --schema hu &
wait

# Work on each HU in parallel
/develop-backend @subscription-pause_backend.md &
/develop-backend @subscription-renew_backend.md &
/develop-backend @subscription-upgrade_backend.md &
wait

# Verify each
/openspec verify change "subscription-pause"
/openspec verify change "subscription-renew"
/openspec verify change "subscription-upgrade"

# Archive completed HUs
/openspec archive change "subscription-pause"
/openspec archive change "subscription-renew"
/openspec archive change "subscription-upgrade"

# Sync all specs to main
/openspec sync-specs --change "subscription-management"
```

---

## 8. Integration with Existing Docs

### 8.1 Referencing Funcional-spec-dd.md

In proposals and designs, reference the functional spec:

```markdown
## Background

This change implements part of the "Gestión de Suscripciones" capability 
defined in `Funcional-spec-dd.md` Section 2.1.

Related use cases:
- Alta de Suscripción (Section 5)
- Baja de Suscripción (Section 5)

Domain entities involved:
- Suscripcion
- Bundle
- CondicionComercial
```

### 8.2 Referencing ARQUITECTURA.md

In designs, reference architecture patterns:

```markdown
## Architecture

This feature follows the Event-Driven architecture defined in `ARQUITECTURA.md`.

Implementation pattern:
- SQS Listener using `LaNacion.Core.Templates.SqsRdr`
- Idempotent message processing
- Outbox Pattern for consistency

Layer structure:
- Domain: [Entities]
- Application: [Event Handlers]
- Infrastructure: [Repositories]
```

### 8.3 Updating data-model.md

After design, update the data model:

```bash
# Trigger data model maintenance
# Use the maintain-data-model skill after implementation
```

### 8.4 File Locations

| Artifact Type | Location |
|--------------|----------|
| OpenSpec Changes | `openspec/changes/` |
| Backend Plans | `ai-specs/changes/` |
| Archived Changes | `openspec/changes/archive/` |
| Project Config | `project.md` |
| Functional Spec | `_docs de proyecto/Funcional-spec-dd.md` |
| Architecture | `_docs de soporte/ARQUITECTURA.md` |
| Data Model | `ai-specs/specs/data-model.md` |

---

## Appendix A: Schema Reference

### epic-mvp-hu Schema (Default)

```
Artifact sequence for epic-driven workflow:

1. proposal.md   - Epic proposal
2. mvp.md        - MVP breakdown
3. [hu-*.md]     - User stories (multiple)
```

### hu Schema

```
Artifact sequence for user story:

1. proposal.md   - What & Why
2. design.md     - How
3. tasks.md      - Checklist
```

### backend Schema

```
Artifact sequence for backend-only change:

1. proposal.md   - Technical proposal
2. design.md     - API/Event design
3. tasks.md      - Implementation tasks
```

---

## Appendix B: Workflow States

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌───────────┐
│ CREATED  │ ──► │  DRAFT   │ ──► │  REVIEW  │ ──► │ APPROVED  │
└──────────┘     └──────────┘     └──────────┘     └───────────┘
                                                                │
                                                                ▼
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌───────────┐
│ REJECTED │ ◄── │  REVIEW  │     │IMPLEMENT │ ──► │COMPLETED  │
└──────────┘     └──────────┘     └──────────┘     └───────────┘
                        │                │
                        ▼                ▼
                 ┌──────────┐     ┌──────────┐
                 │ REVISION │     │ TESTING  │
                 └──────────┘     └──────────┘
```

---

## Appendix C: Naming Conventions

### Change Names

- **Epics**: `kebab-case`, noun phrase (e.g., `bundle-management`)
- **MVPs**: `mvp-[noun]`, (e.g., `mvp-subscription-lifecycle`)
- **HUs**: `verb-noun` or `[TICKET-ID]` (e.g., `create-subscription` or `HU-001`)

### Artifacts

- Proposals: `001_proposal.md`, `002_proposal.md`, etc.
- Designs: `001_design.md`, `002_design.md`, etc.
- Tasks: `tasks.md`

### Backend Plans

- Pattern: `[TICKET-ID]_backend.md`
- Examples: `HU-001_backend.md`, `subscription-creation_backend.md`

---

## Quick Start

For a new feature:

```bash
# 1. Create the change
/openspec new change "my-feature" --schema hu

# 2. Check what to do next
/openspec status --change "my-feature"

# 3. Create proposal
/openspec continue proposal --change "my-feature"

# 4. Create design
/openspec continue design --change "my-feature"

# 5. Create tasks
/openspec continue tasks --change "my-feature"

# 6. Plan implementation
/plan-backend-ticket my-feature

# 7. Implement
/develop-backend @my-feature_backend.md

# 8. Verify & Archive
/openspec verify change "my-feature"
/openspec archive change "my-feature"
```

---

**For questions or issues, refer to:**
- Project config: `project.md`
- Functional spec: `_docs de proyecto/Funcional-spec-dd.md`
- Architecture: `_docs de soporte/ARQUITECTURA.md`
- Standards: `ai-specs/specs/ln-susc-api-standards.mdc`
