# OpenSpec Commands Cheat Sheet

**Project**: LaNacion Subscriptions Module
**Last Updated**: April 24, 2026

---

## Quick Command Reference

### 🚀 Start New Work

| What | Command |
|------|---------|
| New Epic | `/opsx-new "epic-name" --schema epic` |
| New MVP | `/opsx-new "mvp-name" --schema mvp` |
| New User Story (HU) | `/opsx-new "verb-noun" --schema hu` |
| Default (proposal→design→tasks) | `/opsx-new "my-change"` |

### 📋 Progress Through Artifacts

| What | Command |
|------|---------|
| View status | `/opsx-status --change "change-name"` |
| Next artifact | `/opsx-continue proposal --change "change-name"` |
| Get template | `/opsx-instructions [artifact] --change "change-name"` |
| Fast forward | `/opsx-ff-change "change-name"` |

### 🎯 Backend Development

| What | Command |
|------|---------|
| Enrich user story | `/enrich-us HU-001` |
| Plan backend | `/plan-backend-ticket HU-001` |
| Implement API/Listener | `/develop-backend @HU-001_backend.md` |

### ✅ Verify & Complete

| What | Command |
|------|---------|
| Verify implementation | `/opsx-verify change "change-name"` |
| Archive completed | `/opsx-archive change "change-name"` |
| Sync to main | `/opsx-sync-specs --change "change-name"` |

---

## Common Workflows

### Epic → MVP → HU → Implementation

```bash
# 1. Create epic
/opsx-new "bundle-management" --schema epic
/opsx-continue proposal --change "bundle-management"
/opsx-continue mvp --change "bundle-management"

# 2. Create HUs inside epic
/opsx-new "create-bundle" --schema hu
/opsx-continue proposal --change "create-bundle"
/opsx-continue design --change "create-bundle"
/opsx-continue tasks --change "create-bundle"

# 3. Implement
/plan-backend-ticket create-bundle
/develop-backend @create-bundle_backend.md

# 4. Complete
/opsx-verify change "create-bundle"
/opsx-archive change "create-bundle"
```

### Quick Single HU

```bash
/opsx-new "cancel-subscription"
/opsx-continue proposal --change "cancel-subscription"
/opsx-continue design --change "cancel-subscription"
/opsx-continue tasks --change "cancel-subscription"
/plan-backend-ticket cancel-subscription
/develop-backend @cancel-subscription_backend.md
```

### Skills Alternative (if CLI not available)

| What | Skill |
|------|-------|
| Start change | `openspec-new-change` |
| Continue | `openspec-continue-change` |
| Fast forward | `openspec-ff-change` |
| Implement | `implement-backend-plan` |
| Verify | `openspec-verify-change` |
| Archive | `openspec-archive-change` |

---

## File Locations

```
openspec/                          # OpenSpec workspace (Option A - raíz)
├── config.yaml
├── specs/                        # Main specs (after sync)
│   └── {capability}/
│       └── spec.md
├── changes/                     # Active changes
│   ├── bundle-management/        # Epic
│   │   ├── 001_proposal.md
│   │   └── 002_mvp.md
│   ├── create-bundle/           # HU
│   │   ├── 001_proposal.md
│   │   ├── 002_design.md
│   │   └── 003_tasks.md
│   └── archive/                # Completed changes
│       └── {completed-change}/

ai-specs/
└── changes/
    └── HU-001_backend.md        # Backend implementation plans

_docs de proyecto/
└── Funcional-spec-dd.md        # Vision & requirements

_docs de soporte/
├── ARQUITECTURA.md          # Technical architecture
└── OPENSPEC-WORKFLOW.md   # This workflow guide
```

---

## Schema Types

| Schema | Artifacts | Use For |
|--------|-----------|---------|
| `epic` | proposal → mvp | Large features with multiple MVPs |
| `mvp` | proposal → tasks | Single MVP deliverable |
| `hu` | proposal → design → tasks | User story implementation |
| `backend` | proposal → design → tasks | Backend-only feature |
| (default) | proposal → design → tasks | General purpose |

---

## Status Codes

| Status | Meaning |
|--------|---------|
| `ready` | Can be created now |
| `pending` | Waiting for dependencies |
| `draft` | Being edited |
| `review` | Awaiting approval |
| `approved` | Approved, ready to implement |
| `completed` | All done, archived |

---

## Tips

1. **Start small**: Begin with a single HU, not an epic
2. **Iterate fast**: Use `/opsx-ff-change` to skip ahead
3. **Always verify**: Before archiving, run verify
4. **Sync specs**: After archiving, sync to main branch
5. **Reference docs**: Link to `Funcional-spec-dd.md` in proposals
6. **Project config**: Use `project.md` for standards, naming conventions, and agent workflow

---

## Document References

| Document | Purpose |
|----------|---------|
| `project.md` | Project configuration (standards, naming, tech stack) |
| `Vision.md` | Business requirements |
| `ARQUITECTURA.md` | Technical architecture |
| `ln-susc-api-standards.mdc` | API development standards |
| `ln-susc-listener-standards.mdc` | Listener development standards |