---
name: implement-backend-plan-copilot
description: Autonomous backend implementation following a plan. Supports REST APIs and SQS Listeners with automatic testing and validation.
version: 1.0.0
---

# Implement Backend Plan Skill (GitHub Copilot)

Autonomous implementation of backend features following a detailed plan.

## Input

Plan file path (e.g., `@SCRUM-500_backend.md` or `ai-specs/changes/SCRUM-500_backend.md`)

## Execution Steps

### 1. Read and Parse Plan

Extract:
- Backend Type (API or Listener)
- Standards Reference
- Branch name
- All implementation steps
- Testing requirements
- Documentation updates

**Validation**: Verify plan exists and has required sections. **STOP** if invalid.

### 2. Determine Backend Type

Based on Standards Reference:
- `ln-susc-api-standards.mdc` → REST API implementation
- `ln-susc-listener-standards.mdc` → SQS Listener implementation

Announce: "Implementing [API|Listener] backend"

### 3. Verify Prerequisites

Check:
- [ ] Git repository initialized
- [ ] On main/master branch
- [ ] Working directory clean
- [ ] .NET 6 SDK available
- [ ] Required NuGet packages accessible

**STOP** if any prerequisite fails.

### 4. Create Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b [branch-name]
```

Announce: "Created branch: [branch-name]"

### 5. Implement Steps Sequentially (Loop)

For each step (Step 1 through Step N):

**Before**:
- Announce: "Implementing Step X/N: [Step Title]"
- Read requirements
- Identify files to create/modify

**During**:
- Create/modify files as specified
- Follow code examples exactly
- Apply appropriate standards
- Use correct naming conventions
- Include error handling
- Implement transaction management
- Add logging

**After**:
- Verify file created/modified
- Check syntax
- Announce: "✓ Step X/N complete: [Step Title]"

**Pause if**:
- Requirements unclear
- File path doesn't exist
- Code example incomplete
- Missing dependency
- User interrupts

**On pause**: Report progress, describe issue, suggest options, wait for guidance.

### 6. Verify Compilation

```bash
dotnet build
```

**If succeeds**: Continue to testing
**If fails**: **STOP**, report errors, suggest fixes, wait for guidance

### 7. Run Tests

```bash
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=lcov
```

**Verify**:
- [ ] All tests pass
- [ ] Code coverage ≥ 80%

**If succeeds**: Continue to documentation
**If fails**: **STOP**, report failures, show coverage, suggest fixes, wait for guidance

### 8. Update Documentation

**For APIs**:
- `ai-specs/specs/api-spec.yml` (if endpoints changed)

**For both**:
- `ai-specs/specs/data-model.md` (if data model changed)

Verify accuracy and consistency.

Announce: "✓ Documentation updated"

### 9. Show Completion Status

```
## Implementation Complete: [TICKET-ID]

**Backend Type**: [API | Listener]
**Branch**: [branch-name]

### Progress
- Steps completed: N/N ✓
- Build: Success ✓
- Tests: Pass ✓
- Coverage: X% ✓
- Documentation: Updated ✓

### Files Created/Modified
- [list of files]

### Next Steps
1. Review implementation
2. Commit: git add . && git commit -m "[TICKET-ID]: [description]"
3. Push: git push origin [branch-name]
4. Create Pull Request
5. Link PR to ticket

Ready to commit and push?
```

### 10. Optional: Commit and Push

If user confirms:

```bash
git add .
git commit -m "[TICKET-ID]: Implement [feature description]"
git push origin [branch-name]
```

Announce: "✓ Changes committed and pushed"

## Guardrails

- Always read plan completely before starting
- Never skip steps - execute in exact order
- Pause on errors, don't guess
- Verify compilation after implementation
- Run tests before marking complete
- Update documentation before finishing
- Keep code changes focused
- Follow standards strictly (API vs Listener patterns)
- Maintain transaction boundaries (Unit of Work)
- Handle idempotency (Listeners: check MensajesRecibidos)
- Publish events correctly (APIs: Outbox Pattern)
- Use English for all code
- Respect 80% coverage minimum
