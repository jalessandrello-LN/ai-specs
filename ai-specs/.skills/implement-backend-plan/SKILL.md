---
name: implement-backend-plan
description: Implement a backend feature following a generated plan. Supports both REST APIs (LaNacion.Core.Templates.Web.Api.Minimal) and SQS Listeners (ln-SQSlstnr) with automatic agent selection, step-by-step execution, testing, and documentation updates.
license: MIT
compatibility: Requires .NET 6, dotnet CLI, git
metadata:
  author: La Nación
  version: "1.0.0"
  standards:
    - ai-specs/specs/ln-susc-api-standards.mdc
    - ai-specs/specs/ln-susc-listener-standards.mdc
  agents:
    - lanacion-api-developer
    - lanacion-lstnr-developer
---

Implement a backend feature following a detailed implementation plan with autonomous step-by-step execution.

## Agent Adoption

This skill **orchestrates execution** while adopting the technical expertise of:

- **`lanacion-api-developer`** (for REST APIs)
  - Provides: API patterns, CQRS implementation, endpoint design, event publishing
  - Standards: `ai-specs/specs/ln-susc-api-standards.mdc`

- **`lanacion-lstnr-developer`** (for SQS Listeners)
  - Provides: Event processing patterns, idempotency, SQS configuration
  - Standards: `ai-specs/specs/ln-susc-listener-standards.mdc`

**Division of Responsibilities**:
- **This Skill**: Orchestrates multi-step execution, validates continuously, manages state
- **Agent**: Provides technical knowledge, code patterns, architectural guidance
- **Standards**: Define rules, conventions, and quality requirements

**Input**: Plan file path (e.g., `@SCRUM-500_backend.md` or `ai-specs/changes/SCRUM-500_backend.md`)

**Steps**

1. **Read and parse the plan**

   Read the plan file provided by the user.
   
   Extract:
   - Backend Type (API or Listener)
   - Standards Reference (ln-susc-api-standards.mdc or ln-susc-listener-standards.mdc)
   - Branch name
   - All implementation steps (Step 0 through Step N)
   - Testing requirements
   - Documentation updates needed

   **Validation**:
   - Verify plan file exists
   - Verify plan has required sections
   - Verify backend type is clearly specified

   If plan is invalid or incomplete, **STOP** and report the issue.

2. **Auto-select agent role**

   Based on the Standards Reference in the plan:
   
   - If references `ln-susc-api-standards.mdc`:
     - Adopt role: **lanacion-api-developer**
     - Load API-specific patterns and conventions
     - Prepare for REST API implementation
   
   - If references `ln-susc-listener-standards.mdc`:
     - Adopt role: **lanacion-lstnr-developer**
     - Load Listener-specific patterns and conventions
     - Prepare for SQS event processing implementation

   Announce: "Adopting role: [agent-name] for [API|Listener] implementation"

3. **Verify prerequisites**

   Check:
   - [ ] Git repository initialized
   - [ ] On main/master branch
   - [ ] Working directory clean (no uncommitted changes)
   - [ ] .NET 6 SDK available
   - [ ] Required NuGet packages accessible

   If any prerequisite fails, **STOP** and report the issue.

4. **Create feature branch (Step 0)**

   Execute the branch creation from the plan:
   
   ```bash
   git checkout main
   git pull origin main
   git checkout -b [branch-name]
   ```

   Verify branch created successfully.
   
   Announce: "Created branch: [branch-name]"

5. **Implement steps sequentially (loop)**

   For each step in the plan (Step 1 through Step N):

   **Before implementing:**
   - Announce: "Implementing Step X/N: [Step Title]"
   - Read step requirements carefully
   - Identify files to create/modify
   - Review code examples in plan

   **During implementation:**
   - Create or modify files as specified
   - Follow code examples from plan exactly
   - Apply appropriate standards (API or Listener)
   - Use correct naming conventions
   - Include all required using statements
   - Add proper error handling
   - Implement transaction management (Unit of Work)
   - Add logging where appropriate

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

6. **Verify compilation**

   After completing all implementation steps:

   ```bash
   dotnet build
   ```

   **If build succeeds:**
   - Announce: "✓ Build successful"
   - Continue to testing

   **If build fails:**
   - **STOP** and report compilation errors
   - Show error messages
   - Suggest fixes based on error type
   - Wait for user guidance

7. **Run tests (Step 10)**

   Execute the test suite:

   ```bash
   dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=lcov
   ```

   **Verify:**
   - [ ] All tests pass
   - [ ] Code coverage ≥ 80%

   **If tests pass and coverage is sufficient:**
   - Announce: "✓ All tests pass (Coverage: X%)"
   - Continue to documentation

   **If tests fail or coverage is insufficient:**
   - **STOP** and report test failures
   - Show failed test details
   - Show coverage report
   - Suggest fixes
   - Wait for user guidance

8. **Update documentation (Step 11)**

   Based on plan requirements, update:

   **For APIs:**
   - `ai-specs/specs/api-spec.yml` (if endpoints changed)
     - Add new endpoints
     - Update request/response schemas
     - Document status codes
   
   **For both API and Listener:**
   - `ai-specs/specs/data-model.md` (if data model changed)
     - Add new entities
     - Update relationships
     - Document field constraints

   **Verification:**
   - Read updated files
   - Verify accuracy
   - Check consistency with implementation
   - Ensure English language

   Announce: "✓ Documentation updated"

9. **Show completion status**

   Display comprehensive summary:

   ```
   ## Implementation Complete: [TICKET-ID]

   **Backend Type**: [API | Listener]
   **Agent**: [lanacion-api-developer | lanacion-lstnr-developer]
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
   2. Commit changes: git add . && git commit -m "[TICKET-ID]: [description]"
   3. Push branch: git push origin [branch-name]
   4. Create Pull Request
   5. Link PR to ticket

   Ready to commit and push?
   ```

10. **Optional: Commit and push**

    If user confirms, execute:

    ```bash
    git add .
    git commit -m "[TICKET-ID]: Implement [feature description]"
    git push origin [branch-name]
    ```

    Announce: "✓ Changes committed and pushed"

**Output During Implementation**

```
## Implementing: SCRUM-500 (Backend Type: Listener)

Adopting role: lanacion-lstnr-developer

✓ Branch created: feature/SCRUM-500-listener

Implementing Step 1/11: Domain Event
✓ Step 1/11 complete: Domain Event

Implementing Step 2/11: MediatR Handler
✓ Step 2/11 complete: MediatR Handler

Implementing Step 3/11: Repository Interface
✓ Step 3/11 complete: Repository Interface

[...continues through all steps...]

✓ Build successful
✓ All tests pass (Coverage: 87%)
✓ Documentation updated
```

**Output On Completion**

```
## Implementation Complete: SCRUM-500

**Backend Type**: Listener
**Agent**: lanacion-lstnr-developer
**Branch**: feature/SCRUM-500-listener

### Progress
- Steps completed: 11/11 ✓
- Build: Success ✓
- Tests: Pass ✓
- Coverage: 87% ✓
- Documentation: Updated ✓

### Files Created/Modified
- Domain.Events/v1/SuscripcionCreada.cs
- Application/SuscripcionCreadaProcessor.cs
- Application.Interfaces/Persistance/ISuscripcionRepository.cs
- Repositories.SQL/SuscripcionRepository.cs
- Workers/ConfigureServicesExtensions.cs
- Tests/SuscripcionCreadaProcessorTests.cs
- ai-specs/specs/data-model.md

### Next Steps
1. Review implementation
2. Commit changes: git add . && git commit -m "SCRUM-500: Implement subscription sync listener"
3. Push branch: git push origin feature/SCRUM-500-listener
4. Create Pull Request
5. Link PR to ticket

Ready to commit and push?
```

**Output On Pause (Issue Encountered)**

```
## Implementation Paused: SCRUM-500

**Backend Type**: API
**Agent**: lanacion-api-developer
**Progress**: 5/11 steps complete

### Issue Encountered
Step 6 (Repository Implementation): Missing database connection string in appsettings.json

**Current State:**
- Steps 1-5: Complete ✓
- Step 6: Blocked (missing configuration)
- Steps 7-11: Pending

**Options:**
1. Add connection string to appsettings.json manually
2. Update plan to include connection string configuration
3. Skip database operations for now (mock repository)

What would you like to do?
```

**Guardrails**

- **Always read the plan completely before starting** - understand all steps
- **Never skip steps** - execute in exact order specified in plan
- **Pause on errors, don't guess** - report issues and wait for guidance
- **Verify compilation after implementation** - catch errors early
- **Run tests before marking complete** - ensure quality
- **Update documentation before finishing** - keep docs current
- **Keep code changes focused** - implement exactly what's in the plan
- **Follow standards strictly** - API vs Listener patterns must be correct
- **Maintain transaction boundaries** - use Unit of Work correctly
- **Handle idempotency** - for Listeners, always check MensajesRecibidos
- **Publish events correctly** - for APIs, use Outbox Pattern
- **Use English for all code** - comments, variables, error messages
- **Respect 80% coverage minimum** - don't proceed if tests fail

**Integration with Existing Workflow**

This skill replaces the `/develop-backend` command with an autonomous implementation flow:

**Before (Command-based):**
```
/develop-backend @SCRUM-500_backend.md
→ User manually implements each step
→ User manually runs tests
→ User manually updates docs
```

**After (Skill-based):**
```
implement-backend-plan @SCRUM-500_backend.md
→ Autonomous implementation of all steps
→ Automatic testing and validation
→ Automatic documentation updates
→ Pauses only on errors or ambiguity
```

**Compatibility:**
- Works with plans generated by `lanacion-backend-planner`
- Supports both API and Listener patterns
- Integrates with existing standards documents
- Compatible with current project structure
