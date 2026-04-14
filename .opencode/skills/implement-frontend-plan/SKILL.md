---
name: implement-frontend-plan
description: Implement a frontend feature following a generated plan. Supports React component development with TypeScript, state management, testing, and accessibility validation.
license: MIT
compatibility: Requires Node.js, npm/yarn, git
metadata:
  author: La Nación
  version: "1.0.0"
  standards:
    - ai-specs/specs/frontend-standards.mdc
  agents:
    - frontend-developer
---

Implement a frontend feature following a detailed implementation plan with autonomous step-by-step execution.

## Agent Adoption

This skill **orchestrates execution** while adopting the technical expertise of:

- **`frontend-developer`** (for React components)
  - Provides: React patterns, TypeScript types, component design, state management
  - Standards: `ai-specs/specs/frontend-standards.mdc`

**Division of Responsibilities**:
- **This Skill**: Orchestrates multi-step execution, validates continuously, manages state
- **Agent**: Provides technical knowledge, code patterns, UI/UX guidance
- **Standards**: Define rules, conventions, accessibility requirements

**Input**: Plan file path (e.g., `@HU-501_frontend.md` or `ai-specs/changes/HU-501_frontend.md`)

**Steps**

1. **Read and parse the plan**

   Read the plan file provided by the user.
   
   Extract:
   - Feature description
   - Component structure
   - Branch name
   - All implementation steps
   - State management requirements
   - Testing requirements
   - Accessibility requirements
   - Documentation updates needed

   **Validation**:
   - Verify plan file exists
   - Verify plan has required sections
   - Verify component structure is clearly specified

   If plan is invalid or incomplete, **STOP** and report the issue.

2. **Verify prerequisites**

   Check:
   - [ ] Git repository initialized
   - [ ] On main/master branch
   - [ ] Working directory clean (no uncommitted changes)
   - [ ] Node.js available
   - [ ] npm/yarn available
   - [ ] React project structure exists

   If any prerequisite fails, **STOP** and report the issue.

3. **Create feature branch (Step 0)**

   Execute the branch creation from the plan:
   
   ```bash
   git checkout main
   git pull origin main
   git checkout -b [branch-name]
   ```

   Verify branch created successfully.
   
   Announce: "Created branch: [branch-name]"

4. **Implement steps sequentially (loop)**

   For each step in the plan (Step 1 through Step N):

   **Before implementing:**
   - Announce: "Implementing Step X/N: [Step Title]"
   - Read step requirements carefully
   - Identify files to create/modify
   - Review code examples in plan

   **During implementation:**
   - Create or modify files as specified
   - Follow code examples from plan exactly
   - Apply frontend standards
   - Use TypeScript types correctly
   - Implement proper state management
   - Add accessibility attributes (ARIA)
   - Include proper error handling
   - Add loading states
   - Implement responsive design

   **Component Implementation Checklist:**
   - [ ] TypeScript interfaces/types defined
   - [ ] Props properly typed
   - [ ] State management implemented
   - [ ] Event handlers defined
   - [ ] Accessibility attributes added (aria-label, role, etc.)
   - [ ] Error boundaries implemented
   - [ ] Loading states handled
   - [ ] Responsive design applied
   - [ ] CSS/styling applied

   **After implementing:**
   - Verify file created/modified successfully
   - Check syntax (basic validation)
   - Announce: "✓ Step X/N complete: [Step Title]"

   **Pause if:**
   - Step requirements are unclear or ambiguous
   - File path doesn't exist and can't be created
   - Code example is incomplete or contradictory
   - Missing dependency or package
   - User interrupts

   **On pause:**
   - Report current progress (X/N steps complete)
   - Describe the issue encountered
   - Suggest options to resolve
   - Wait for user guidance

5. **Install dependencies (if new packages added)**

   If the implementation added new dependencies:

   ```bash
   npm install
   # or
   yarn install
   ```

   Verify installation successful.

6. **Verify compilation**

   After completing all implementation steps:

   ```bash
   npm run build
   # or
   yarn build
   ```

   **If build succeeds:**
   - Announce: "✓ Build successful"
   - Continue to testing

   **If build fails:**
   - **STOP** and report compilation errors
   - Show error messages
   - Suggest fixes based on error type
   - Wait for user guidance

7. **Run tests**

   Execute the test suite:

   ```bash
   npm test
   # or
   yarn test
   ```

   **Verify:**
   - [ ] All component tests pass
   - [ ] Snapshot tests pass (if applicable)
   - [ ] Integration tests pass
   - [ ] Code coverage ≥ 80%

   **If tests pass and coverage is sufficient:**
   - Announce: "✓ All tests pass (Coverage: X%)"
   - Continue to accessibility validation

   **If tests fail or coverage is insufficient:**
   - **STOP** and report test failures
   - Show failed test details
   - Show coverage report
   - Suggest fixes
   - Wait for user guidance

8. **Validate accessibility**

   Run accessibility checks:

   ```bash
   npm run lint:a11y
   # or check manually
   ```

   **Verify:**
   - [ ] All interactive elements have labels
   - [ ] Proper ARIA attributes used
   - [ ] Keyboard navigation works
   - [ ] Color contrast meets WCAG standards
   - [ ] Screen reader compatible

   **If accessibility issues found:**
   - Report issues
   - Suggest fixes
   - Apply fixes if straightforward
   - Otherwise, wait for guidance

   Announce: "✓ Accessibility validated"

9. **Run linter**

   Execute linting:

   ```bash
   npm run lint
   # or
   yarn lint
   ```

   **If linting passes:**
   - Announce: "✓ Linting passed"
   - Continue to documentation

   **If linting fails:**
   - Apply auto-fixes if available: `npm run lint:fix`
   - Report remaining issues
   - Suggest manual fixes
   - Wait for guidance if complex

10. **Update documentation**

    Based on plan requirements, update:

    - Component documentation (JSDoc/TSDoc)
    - Storybook stories (if applicable)
    - README.md (if new feature)
    - API integration docs (if backend calls added)

    **Verification:**
    - Read updated files
    - Verify accuracy
    - Check consistency with implementation
    - Ensure English language

    Announce: "✓ Documentation updated"

11. **Show completion status**

    Display comprehensive summary:

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
    1. Review implementation in browser
    2. Test user interactions manually
    3. Commit changes: git add . && git commit -m "[TICKET-ID]: [description]"
    4. Push branch: git push origin [branch-name]
    5. Create Pull Request
    6. Link PR to ticket

    Ready to commit and push?
    ```

12. **Optional: Commit and push**

    If user confirms, execute:

    ```bash
    git add .
    git commit -m "[TICKET-ID]: Implement [feature description]"
    git push origin [branch-name]
    ```

    Announce: "✓ Changes committed and pushed"

**Output During Implementation**

```
## Implementing: HU-501 (Frontend Feature)

✓ Branch created: feature/HU-501-subscription-form

Implementing Step 1/8: Create SubscriptionForm component
✓ Step 1/8 complete: Create SubscriptionForm component

Implementing Step 2/8: Add form validation
✓ Step 2/8 complete: Add form validation

Implementing Step 3/8: Implement state management
✓ Step 3/8 complete: Implement state management

[...continues through all steps...]

✓ Build successful
✓ All tests pass (Coverage: 92%)
✓ Accessibility validated
✓ Linting passed
✓ Documentation updated
```

**Output On Completion**

```
## Implementation Complete: HU-501

**Feature**: Subscription Form with Validation
**Branch**: feature/HU-501-subscription-form

### Progress
- Steps completed: 8/8 ✓
- Build: Success ✓
- Tests: Pass ✓
- Coverage: 92% ✓
- Accessibility: Validated ✓
- Linting: Passed ✓
- Documentation: Updated ✓

### Components Created/Modified
- SubscriptionForm
- FormInput
- ValidationMessage
- SubmitButton

### Files Created/Modified
- src/components/SubscriptionForm/SubscriptionForm.tsx
- src/components/SubscriptionForm/SubscriptionForm.test.tsx
- src/components/SubscriptionForm/SubscriptionForm.module.css
- src/components/FormInput/FormInput.tsx
- src/hooks/useFormValidation.ts
- src/types/subscription.ts

### Next Steps
1. Review implementation in browser
2. Test user interactions manually
3. Commit changes: git add . && git commit -m "HU-501: Implement subscription form with validation"
4. Push branch: git push origin feature/HU-501-subscription-form
5. Create Pull Request
6. Link PR to ticket

Ready to commit and push?
```

**Output On Pause (Issue Encountered)**

```
## Implementation Paused: HU-501

**Feature**: Subscription Form
**Progress**: 4/8 steps complete

### Issue Encountered
Step 5 (API Integration): Missing API endpoint definition for subscription creation

**Current State:**
- Steps 1-4: Complete ✓
- Step 5: Blocked (missing API endpoint)
- Steps 6-8: Pending

**Options:**
1. Define API endpoint in api-spec.yml first
2. Mock API response for now
3. Update plan to clarify API integration

What would you like to do?
```

**Guardrails**

- **Always read the plan completely before starting** - understand all steps
- **Never skip steps** - execute in exact order specified in plan
- **Pause on errors, don't guess** - report issues and wait for guidance
- **Verify compilation after implementation** - catch errors early
- **Run tests before marking complete** - ensure quality
- **Validate accessibility** - WCAG compliance is mandatory
- **Run linter** - code style consistency is required
- **Update documentation before finishing** - keep docs current
- **Keep code changes focused** - implement exactly what's in the plan
- **Follow frontend standards strictly** - React patterns, TypeScript, accessibility
- **Use TypeScript properly** - no `any` types unless absolutely necessary
- **Implement error boundaries** - handle component errors gracefully
- **Add loading states** - improve UX during async operations
- **Make responsive** - mobile-first design approach
- **Use English for all code** - comments, variables, error messages
- **Respect 80% coverage minimum** - don't proceed if tests fail

**Integration with Existing Workflow**

This skill replaces the `/develop-frontend` command with an autonomous implementation flow:

**Before (Command-based):**
```
/develop-frontend @HU-501_frontend.md
→ User manually implements each step
→ User manually runs tests
→ User manually validates accessibility
→ User manually updates docs
```

**After (Skill-based):**
```
implement-frontend-plan @HU-501_frontend.md
→ Autonomous implementation of all steps
→ Automatic testing and validation
→ Automatic accessibility checks
→ Automatic documentation updates
→ Pauses only on errors or ambiguity
```

**Compatibility:**
- Works with plans generated by frontend planning agents
- Supports React with TypeScript
- Integrates with existing frontend standards
- Compatible with current project structure
- Supports various state management solutions (Context, Redux, Zustand, etc.)
