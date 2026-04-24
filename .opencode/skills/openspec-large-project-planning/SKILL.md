---
name: openspec-large-project-planning
description: Execute the complete large project planning workflow using OpenSpec. Use when starting a new large project with Vision.md and arquitectura.md documents. Extracts requirements, defines epics, MVPs, and generates HU backlog following the OpenSpec incremental approach.
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: opencode
  version: "1.1"
  generatedBy: "1.1.0"
---

Execute a complete large project planning workflow using OpenSpec.

**Input**: Path to Vision.md and arquitectura.md documents, or project context.

**When to Use**:

- Starting a new large project
- Planning a major initiative
- Breaking down a big requirements document into epics and HUs
- Setting up OpenSpec workflow for a microservices/event-driven architecture

---

## Preflight

Check if OpenSpec is initialized:

```bash
openspec status --json 2>&1 || echo "NOT_INITIALIZED"
```

**If not initialized:**
> OpenSpec isn't set up in this project yet. Run `openspec init` first, then come back to `/plan-large-project`.

---

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│           LARGE PROJECT PLANNING WORKFLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PHASE 1: Analyze Documents                                      │
│  ├─ Read Vision.md (requirements)                              │
│  ├─ Read arquitectura.md (microservices/events)                 │
│  └─ Read project.md (configuration & standards)                 │
│                                                                  │
│  PHASE 2: Create Planning Change                                │
│  ├─ openspec new change "planning-full-project"                 │
│  └─ Generate: proposal.md, specs/, design.md, tasks.md         │
│                                                                  │
│  PHASE 3: Execute Planning                                       │
│  └─ openspec apply "planning-full-project"                      │
│                                                                  │
│  PHASE 4: Generate Artifacts                                    │
│  ├─ Epic Backlog                                                 │
│  ├─ MVP Roadmap                                                  │
│  ├─ HU List (with naming conventions)                          │
│  └─ Microservices Matrix                                         │
│                                                                  │
│  PHASE 5: Sync & Archive                                        │
│  ├─ openspec sync "planning-full-project"                       │
│  └─ openspec archive "planning-full-project"                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Analyze Documents

### 1.1 Read Vision.md

If Vision.md exists, read and extract:
- Business objectives
- High-level requirements
- User personas/stories
- Success criteria

```markdown
## Requirements from Vision.md

| ID | Requirement | Priority | Domain |
|----|-------------|----------|--------|
| REQ-001 | [requirement] | Must | [domain] |
| REQ-002 | [requirement] | Should | [domain] |
```

### 1.2 Read arquitectura.md

If arquitectura.md exists, extract:
- Microservices list
- Event schemas
- Service boundaries
- Integration patterns

```markdown
## Architecture from arquitectura.md

### Microservices

| Service | Domain | Responsibilities |
|---------|--------|------------------|
| [Service] | [Domain] | [Responsibilities] |

### Events

| Event | Producer | Consumers | Purpose |
|-------|----------|-----------|---------|
| [Event] | [Service] | [Consumers] | [Purpose] |
```

### 1.3 Read project.md (Configuration)

If `project.md` exists in the project root, read and extract:
- Project type and stack technology
- Architecture foundations
- Naming conventions
- Standards to apply
- Agent workflow integration

```markdown
## Project Configuration from project.md

**Project:** [name]
**Type:** [backend/frontend/full-stack]
**Stack:** [.NET/.NET 6/Clean Architecture/CQRS/Event-Driven]

**Standards:**
- Base: base-standards.mdc
- API: ln-susc-api-standards.mdc (if applicable)
- Listener: ln-susc-listener-standards.mdc (if applicable)
- Frontend: frontend-standards.mdc (if applicable)

**Naming Conventions:**
- Commands: cmd-{verb}-{entity}
- Events: evt-{squad}-{entity}-{verb-past}
- Queues: {product}-{env}-sqs-{event}
```

### 1.4 Ask for Missing Information

If documents don't exist, ask user:

> I need to analyze your requirements. Please provide:
> 1. **Vision.md** path or paste its content - What problem are we solving?
> 2. **arquitectura.md** path or paste its content - What's the architecture?
> 3. **project.md** path (optional) - Project configuration
>
> Or tell me:
> - What business problem are we solving?
> - What microservices do you need?
> - What events will they exchange?

---

## Phase 2: Create Planning Change

### 2.1 Create the Change

```bash
openspec new change "planning-full-project"
```

### 2.2 Generate Proposal

Create `openspec/changes/planning-full-project/proposal.md`:

```markdown
# Proposal: Full Project Planning

## Why

[Extract from Vision.md - business problem/opportunity]

## What Changes

- Extract and structure all requirements from Vision.md
- Define epicas based on business domains from arquitectura.md
- Define MVPs based on delivery value
- Generate individual HUs for each MVP
- Map HUs to microservices and events
- Apply project-specific configuration from project.md

## Capabilities

### Planning Capabilities

- **requirements-extraction**: Extract requirements from Vision.md
- **architecture-analysis**: Analyze arquitectura.md for service boundaries
- **project-configuration**: Apply project.md configuration (standards, naming conventions)
- **epic-definition**: Define epicas based on domains
- **mvp-definition**: Define MVPs based on value delivery
- **hu-generation**: Generate individual user stories
- **microservices-mapping**: Map HUs to microservices and events

## Impact

This is a planning-only change that generates the implementation backlog.
No production code is affected.

**Source Documents:**
- Vision.md: [path or summary]
- arquitectura.md: [path or summary]
- project.md: [path or summary] - Project configuration and standards
```

### 2.3 Generate Specs

Create specs for each planning capability:

**specs/requirements-extraction/spec.md**:
```markdown
## ADDED Requirements

### Requirement: Requirements Extraction

The system SHALL extract all requirements from Vision.md organized by:
- Functional requirements
- Non-functional requirements
- Business rules
- Integration points

#### Scenario: Extract functional requirements

- **WHEN** analyzing Vision.md
- **THEN** identify all user-facing features
- **AND** categorize by domain/bounded context
- **AND** document acceptance criteria

#### Scenario: Extract non-functional requirements

- **WHEN** analyzing Vision.md
- **THEN** identify performance requirements
- **AND** identify security requirements
- **AND** identify scalability requirements
```

**specs/architecture-analysis/spec.md**:
```markdown
## ADDED Requirements

### Requirement: Architecture Analysis

The system SHALL analyze arquitectura.md to identify:
- Microservices list and responsibilities
- Event schemas
- Integration patterns
- Data ownership boundaries

#### Scenario: Identify microservices

- **WHEN** analyzing arquitectura.md
- **THEN** list all microservices
- **AND** define each service's domain
- **AND** document service boundaries
```

**specs/epic-definition/spec.md**:
```markdown
## ADDED Requirements

### Requirement: Epic Definition

The system SHALL group related requirements into epicas based on:
- Business domain/bounded context
- Common user journey
- Shared infrastructure
- Deployment boundaries
```

**specs/mvp-definition/spec.md**:
```markdown
## ADDED Requirements

### Requirement: MVP Definition

The system SHALL define MVPs based on:
- Value delivery to users
- Technical dependencies
- Risk mitigation
- Fast feedback cycles
```

**specs/hu-generation/spec.md**:
```markdown
## ADDED Requirements

### Requirement: User Story Generation

The system SHALL generate individual user stories (HUs) for each MVP with:
- Clear user value
- Independent implementation
- Testable acceptance criteria
- Microservice assignment
- Event requirements
```

**specs/microservices-mapping/spec.md**:
```markdown
## ADDED Requirements

### Requirement: Microservice Assignment

The system SHALL assign each HU to the appropriate microservice based on:
- Domain ownership
- Data responsibility
- Event publishing/consuming role
```

**specs/output-generation/spec.md**:
```markdown
## ADDED Requirements

### Requirement: Output Generation

The system SHALL generate planning documents:
- Epic Backlog
- MVP Roadmap
- HU List per MVP
- Microservices Assignment Matrix
```

### 2.4 Generate Design

Create `design.md`:

```markdown
# Design: Full Project Planning

## Context

This planning phase transforms Vision.md and arquitectura.md into
an actionable implementation backlog following microservices and
event-driven architecture.

## Goals / Non-Goals

**Goals:**
- Complete requirements coverage from Vision.md
- Clear microservices boundaries from arquitectura.md
- Independent, testable HUs
- Logical MVP groupings with incremental value

**Non-Goals:**
- Detailed API design (per HU)
- Database schema design (per HU)
- Infrastructure provisioning
- Deployment automation

## Decisions

### Decision 1: Epic Organization

Epicas are organized by business domain/bounded context, aligned with
microservices from arquitectura.md.

### Decision 2: MVP Prioritization

MVPs are prioritized by:
1. Core business value
2. Technical dependencies
3. Risk early detection
4. Fastest feedback loop

### Decision 3: HU Independence

Each HU is designed to be implementable without other HUs in the same
MVP, with proper use of events for eventual consistency.

### Decision 4: Event-First Design

HUs involving state changes must:
- Define the resulting event
- Specify event schema
- Identify consumers
- Handle eventual consistency

### Decision 5: Project Configuration

Apply project-specific configuration from project.md:
- Use defined naming conventions (commands, events, queues)
- Apply relevant standards (API, Listener, Frontend)
- Follow defined architecture patterns (Clean Architecture, CQRS)
- Use specified technology stack

## Source Documents

**Vision.md:**
- Path: [path]
- Key requirements: [list]

**arquitectura.md:**
- Path: [path]
- Microservices: [count]
- Events: [count]

**project.md:**
- Path: [path]
- Standards: [list of applicable standards]
- Naming conventions: [conventions to follow]
```

### 2.5 Generate Tasks

Create `tasks.md`:

```markdown
# Tasks: Full Project Planning

## 1. Requirements Extraction

- [ ] 1.1 Read and analyze Vision.md
- [ ] 1.2 Extract functional requirements
- [ ] 1.3 Extract non-functional requirements
- [ ] 1.4 Document all requirements with IDs (REQ-XX)

## 2. Architecture Analysis

- [ ] 2.1 Read and analyze arquitectura.md
- [ ] 2.2 List all microservices
- [ ] 2.3 Document service responsibilities
- [ ] 2.4 Extract event schemas
- [ ] 2.5 Document integration patterns

## 2b. Project Configuration

- [ ] 2b.1 Read and analyze project.md (if exists)
- [ ] 2b.2 Extract technology stack and standards
- [ ] 2b.3 Document naming conventions
- [ ] 2b.4 Identify applicable standards (API, Listener, Frontend)
- [ ] 2b.5 Apply project configuration to planning artifacts

## 3. Epic Definition

- [ ] 3.1 Group requirements by domain
- [ ] 3.2 Define epic for each domain
- [ ] 3.3 Write epic descriptions
- [ ] 3.4 Link requirements to epicas
- [ ] 3.5 Assign microservices to epicas

## 4. MVP Definition

- [ ] 4.1 Analyze dependencies between requirements
- [ ] 4.2 Define MVP for each epic
- [ ] 4.3 Prioritize MVPs across epics
- [ ] 4.4 Document MVP scope

## 5. HU Generation

- [ ] 5.1 Generate HU for each requirement
- [ ] 5.2 Write user story format (As a... I want... so that...)
- [ ] 5.3 Define acceptance criteria
- [ ] 5.4 Assign to microservices
- [ ] 5.5 Assign to MVPs
- [ ] 5.6 Define required events

## 6. Output Generation

- [ ] 6.1 Generate Epic Backlog document
- [ ] 6.2 Generate MVP Roadmap document
- [ ] 6.3 Generate HU List per MVP
- [ ] 6.4 Generate Microservices Assignment Matrix
- [ ] 6.5 Create individual HU change scaffolds
```

---

## Phase 3: Execute Planning

### 3.1 Apply the Planning Change

```bash
openspec apply planning-full-project
```

### 3.2 Generate Epic Backlog

Create `openspec/changes/planning-full-project/epic-backlog.md`:

```markdown
# Epic Backlog

## Overview

This document contains all epicas defined from Vision.md and arquitectura.md.

## Epicas

### EPIC-01: [Domain Name]

**Description:** [Brief description from requirements]

**Microservice:** [Service Name]

**Requirements:**
- REQ-001: [requirement]
- REQ-002: [requirement]

**MVPs:**
- MVP 1.1: [MVP name]
- MVP 1.2: [MVP name]

**Events:**
- [Event Name] - [Purpose]

---

### EPIC-02: [Domain Name]

[... repeat for each epic ...]
```

### 3.3 Generate MVP Roadmap

Create `openspec/changes/planning-full-project/mvp-roadmap.md`:

```markdown
# MVP Roadmap

## Overview

This document defines the release plan based on MVP prioritization.

## Release Schedule

### Release 1: MVP 1.1 + MVP 2.1

**Date:** TBD
**Value:** [Core business value]

**MVPs:**
- MVP 1.1: [description]
- MVP 2.1: [description]

**HUs:** HU-001, HU-002, HU-005, HU-006

**Events:** [list]

---

### Release 2: MVP 1.2 + MVP 2.2

**Date:** TBD
**Value:** [Extended functionality]

[... continue for each release ...]
```

### 3.4 Generate HU List

Create `openspec/changes/planning-full-project/hu-list.md`:

```markdown
# User Story (HU) List

## By MVP

### MVP 1.1: [MVP Name]

| HU ID | Title | Microservice | Events | Status |
|-------|-------|-------------|--------|--------|
| HU-001 | [title] | [service] | [events] | Ready |
| HU-002 | [title] | [service] | [events] | Ready |

### MVP 1.2: [MVP Name]

| HU ID | Title | Microservice | Events | Status |
|-------|-------|-------------|--------|--------|
| HU-003 | [title] | [service] | [events] | Ready |

---

## HU Details

### HU-001: [Title]

**As a:** [persona]
**I want:** [feature]
**So that:** [benefit]

**Acceptance Criteria:**
- [ ] [criterion 1]
- [ ] [criterion 2]

**Microservice:** [service]
**MVP:** MVP 1.1
**Epic:** EPIC-01
**Events Produced:** [events]
**Events Consumed:** [events]

[... repeat for each HU ...]
```

### 3.5 Generate Microservices Matrix

Create `openspec/changes/planning-full-project/microservices-matrix.md`:

```markdown
# Microservices Assignment Matrix

## Overview

This document maps all HUs to microservices and their event responsibilities.

## Microservices

### [Service Name]

**Domain:** [domain]
**Responsibilities:** [list]

**HUs Assigned:**
- HU-001: [title]
- HU-002: [title]

**Events Published:**
- [Event Name]: [schema summary]

**Events Consumed:**
- [Event Name]: [from service]

---

## Event Catalog

| Event | Schema | Producer | Consumers |
|-------|--------|----------|-----------|
| [Event] | [schema] | [service] | [services] |
```

---

## Phase 4: Create HU Scaffolds

### 4.1 Create Individual HU Changes

For each HU in the backlog, create a change scaffold:

```bash
# Example for HU-001
openspec new change "hu-001-[slug]"

# The change will contain:
# - proposal.md (pre-filled with HU details)
# - specs/ (empty, ready to fill)
# - design.md (empty, ready to fill)
# - tasks.md (template ready)
```

### 4.2 HU Proposal Template (Pre-filled)

```markdown
# Proposal: HU-[ID] - [Title]

## Why

[Extract from HU definition]

**Source:** REQ-[XX]
**Priority:** [Must/Should/Could]
**MVP:** [MVP-ID]
**Epic:** [EPIC-ID]
**Project Standards:** [from project.md - e.g., ln-susc-api-standards.mdc]

## What Changes

- [list of changes]

## Capabilities

### New Capabilities
- **[capability-name]**: [description]

### Modified Capabilities
- None / [modified capability]

## Impact

- **Service:** [microservice name]
- **Endpoint:** [API endpoint if applicable]
- **Database:** [tables if applicable]
- **Events Published:** [events]
- **Events Consumed:** [events]
- **Consumers:** [downstream services]
- **Naming Convention:** [from project.md - e.g., cmd-{verb}-{entity}]
```

### 4.3 HU Tasks Template (Pre-filled)

```markdown
# Tasks: HU-[ID] - [Title]

## 1. Domain Layer

- [ ] 1.1 [Domain task]
- [ ] 1.2 [Entity creation]
- [ ] 1.3 [Domain event creation]

## 2. Application Layer

- [ ] 2.1 [Command/Query creation]
- [ ] 2.2 [Validator creation]
- [ ] 2.3 [Handler implementation]

## 3. Infrastructure Layer

- [ ] 3.1 [Repository implementation]
- [ ] 3.2 [Event publishing]
- [ ] 3.3 [Database migrations]

## 4. API Layer (if applicable)

- [ ] 4.1 [Endpoint creation]
- [ ] 4.2 [DTOs]
- [ ] 4.3 [Exception handling]

## 5. Event Handlers (if applicable)

- [ ] 5.1 [Event handler for consumed events]

## 6. Testing

- [ ] 6.1 [Unit tests]
- [ ] 6.2 [Integration tests]

## 7. Documentation

- [ ] 7.1 [API docs]
- [ ] 7.2 [OpenAPI update]
```

---

## Phase 5: Sync & Archive

### 5.1 Sync Planning Specs

```bash
openspec sync planning-full-project
```

This merges delta specs into main specs.

### 5.2 Archive Planning Change

```bash
openspec archive planning-full-project
```

---

## Output Summary

After completion, provide this summary:

```markdown
## Planning Complete

**Changes Created:**

1. **Planning Change:**
   - `planning-full-project/` - Complete planning artifacts
   - Epic Backlog: [count] epicas
   - MVP Roadmap: [count] MVPs
   - HU List: [count] user stories

2. **HU Change Scaffolds:**
   - `hu-001-[slug]/`
   - `hu-002-[slug]/`
   - ... (one per HU)

**Documents Generated:**
- `epic-backlog.md` - All epicas
- `mvp-roadmap.md` - Release schedule
- `hu-list.md` - Complete HU backlog
- `microservices-matrix.md` - Service mapping

**Next Steps:**

1. Review the planning documents
2. Adjust epic/MVP/HU definitions as needed
3. Start implementing HUs using `/opsx-apply hu-XXX`
4. Each HU follows: apply -> verify -> sync -> archive
```

---

## Guardrails

- Always read Vision.md and arquitectura.md before generating planning artifacts
- Group requirements into epicas aligned with microservices
- Prioritize MVPs based on business value and dependencies
- Ensure each HU is independent and testable
- Pre-fill HU proposals with all known information from planning
- Create HU scaffolds for all HUs, not just the first MVP
- Archive the planning change after generating all artifacts

---

## Related Commands

| Command | Purpose |
|---------|---------|
| `/opsx-new` | Start a new change |
| `/opsx-apply` | Implement HU tasks |
| `/opsx-ff` | Fast-forward artifacts |
| `/plan-large-project` | Run this full planning workflow |
