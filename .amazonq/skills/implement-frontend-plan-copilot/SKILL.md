---
name: implement-frontend-plan-copilot
description: Autonomous frontend implementation following a plan. Supports React with TypeScript, testing, and accessibility validation.
version: 1.0.0
---

# Implement Frontend Plan Skill (GitHub Copilot)

Autonomous implementation of frontend features following a detailed plan.

## Input

Plan file path (e.g., `@HU-501_frontend.md` or `ai-specs/changes/HU-501_frontend.md`)

## Execution Steps

### 1. Read and Parse Plan

Extract:
- Feature description
- Component structure
- Branch name
- All implementation steps
- State management requirements
- Testing requirements
- Accessibility requirements
- Documentation updates

**Validation**: Verify plan exists and has required sections. **STOP** if invalid.

### 2. Verify Prerequisites

Check:
- [ ] Git repository initialized
- [ ] On main/master branch
- [ ] Working directory clean
- [ ] Node.js available
- [ ] npm/yarn available
- [ ] React project structure exists

**STOP** if any prerequisite fails.

### 3. Create Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b [branch-name]
```

Announce: "Created branch: [branch-name]"

### 4. Implement Steps Sequentially (Loop)

For each step (Step 1 through Step N):

**Before**:
- Announce: "Implementing Step X/N: [Step Title]"
- Read requirements
- Identify files to create/modify

**During**:
- Create/modify files as specified
- Follow code examples exactly
- Apply frontend standards
- Use TypeScript types correctly
- Implement proper state management
- Add accessibility attributes (ARIA)
- Include error handling
- Add loading states
- Implement responsive design

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

### 5. Install Dependencies

If new packages added:

```bash
npm install
# or yarn install
```

### 6. Verify Compilation

```bash
npm run build
# or yarn build
```

**If succeeds**: Continue to testing
**If fails**: **STOP**, report errors, suggest fixes, wait for guidance

### 7. Run Tests

```bash
npm test
# or yarn test
```

**Verify**:
- [ ] All component tests pass
- [ ] Snapshot tests pass
- [ ] Integration tests pass
- [ ] Code coverage ≥ 80%

**If succeeds**: Continue to accessibility validation
**If fails**: **STOP**, report failures, show coverage, suggest fixes, wait for guidance

### 8. Validate Accessibility

Check:
- [ ] Interactive elements have labels
- [ ] Proper ARIA attributes used
- [ ] Keyboard navigation works
- [ ] Color contrast meets WCAG
- [ ] Screen reader compatible

**If issues found**: Report, suggest fixes, apply if straightforward, otherwise wait for guidance.

Announce: "✓ Accessibility validated"

### 9. Run Linter

```bash
npm run lint
# or yarn lint
```

**If passes**: Continue to documentation
**If fails**: Apply auto-fixes (`npm run lint:fix`), report remaining issues, wait for guidance if complex

### 10. Update Documentation

Update:
- Component documentation (JSDoc/TSDoc)
- Storybook stories (if applicable)
- README.md (if new feature)
- API integration docs (if backend calls added)

Verify accuracy and consistency.

Announce: "✓ Documentation updated"

### 11. Show Completion Status

```
## Implementation Complete: [TICKET-ID]

**Feature**: [Feature Name]
**Branch**: [branch-name]

### Progress
- Steps completed: N/N ✓
- Build: Success ✓
- Tests: Pass ✓
- Coverage: X% ✓
- Accessibility: Validated ✓
- Linting: Passed ✓
- Documentation: Updated ✓

### Components Created/Modified
- [list of components]

### Files Created/Modified
- [list of files]

### Next Steps
1. Review in browser
2. Test user interactions manually
3. Commit: git add . && git commit -m "[TICKET-ID]: [description]"
4. Push: git push origin [branch-name]
5. Create Pull Request
6. Link PR to ticket

Ready to commit and push?
```

### 12. Optional: Commit and Push

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
- Validate accessibility (WCAG compliance mandatory)
- Run linter (code style consistency required)
- Update documentation before finishing
- Keep code changes focused
- Follow frontend standards strictly
- Use TypeScript properly (no `any` unless necessary)
- Implement error boundaries
- Add loading states
- Make responsive (mobile-first)
- Use English for all code
- Respect 80% coverage minimum
