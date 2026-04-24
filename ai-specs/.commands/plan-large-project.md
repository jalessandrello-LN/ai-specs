---
description: Execute the complete large project planning workflow using OpenSpec. Starts from Vision.md and arquitectura.md documents, extracts requirements, defines epics, MVPs, and generates HU backlog.
---

Execute a complete large project planning workflow using OpenSpec.

**Usage**: `/plan-large-project`

**When to Use**:

- Starting a new large project
- Planning a major initiative
- Breaking down Vision.md and arquitectura.md into epicas and HUs
- Setting up OpenSpec workflow for microservices/event-driven architecture

---

## What This Does

This command executes a 5-phase workflow:

```
┌─────────────────────────────────────────────────────────────────┐
│           LARGE PROJECT PLANNING WORKFLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PHASE 1: Analyze Documents                                      │
│  ├─ Read Vision.md (requirements)                              │
│  ├─ Read arquitectura.md (microservices/events)                 │
│  └─ Read project.md (configuration & standards)                     │
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

## Steps

### 1. Check Prerequisites

Verify OpenSpec is initialized:

```bash
openspec status --json 2>&1 || echo "NOT_INITIALIZED"
```

**If not initialized:**
> OpenSpec isn't set up. Run `openspec init` first.

### 2. Analyze Source Documents

Look for source documents in common locations:

**Vision.md** (requirements):
- `./docs/Vision.md`
- `./Vision.md`
- `./_docs de proyecto/Vision.md`

**arquitectura.md** (architecture):
- `./docs/arquitectura.md`
- `./arquitectura.md`
- `./docs/architecture.md`
- `./_docs de soporte/ARQUITECTURA.md`

**project.md** (configuration):
- `./project.md`
- `./project.json`

If not found, ask the user to provide paths or content.

### 2.1 Document Priority

The skill analyzes documents in order of priority:
1. **Vision.md** - Business requirements and objectives
2. **arquitectura.md** - Technical architecture (microservices, events)
3. **project.md** - Project configuration and standards

### 3. Create Planning Change

```bash
openspec new change "planning-full-project"
```

### 4. Load the Skill

Load the `openspec-large-project-planning` skill to execute the workflow:

```
Load skill: openspec-large-project-planning
```

The skill will:
1. Read and analyze Vision.md and arquitectura.md
2. Generate all planning artifacts
3. Create Epic Backlog, MVP Roadmap, HU List
4. Scaffold individual HU changes

---

## Output

After completion, the user will have:

1. **Planning Change** (`planning-full-project/`):
   - `proposal.md` - Planning scope
   - `specs/` - Requirements specs
   - `design.md` - Planning decisions
   - `tasks.md` - Planning tasks

2. **Generated Documents**:
   - `epic-backlog.md` - All epicas with requirements
   - `mvp-roadmap.md` - Release schedule
   - `hu-list.md` - Complete HU backlog
   - `microservices-matrix.md` - Service mapping

3. **HU Change Scaffolds**:
   - One change per HU (e.g., `hu-001-register-customer/`)
   - Pre-filled with HU details from planning

---

## Next Steps

After `/plan-large-project` completes:

1. Review generated planning documents
2. Adjust epicas/MVPs/HUs as needed
3. Implement HUs one by one:
   ```
   /opsx-apply hu-001-[slug]
   /opsx-verify hu-001-[slug]
   /opsx-sync hu-001-[slug]
   /opsx-archive hu-001-[slug]
   ```

---

## Guardrails

- Always analyze all three documents: Vision.md, arquitectura.md, and project.md
- Apply project-specific standards from project.md
- Use naming conventions defined in project.md
- Group requirements into epicas aligned with microservices
- Prioritize MVPs based on business value
- Ensure each HU is independent
- Create HU scaffolds for all HUs, not just first MVP