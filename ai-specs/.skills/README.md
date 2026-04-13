# AI Skills for La Nación Development

This directory contains AI skills that enable autonomous, multi-step implementation workflows for backend and frontend features.

## What are Skills?

Skills are advanced AI capabilities that go beyond simple commands. They:

- **Execute multiple steps autonomously** - Loop through implementation steps without manual intervention
- **Maintain state** - Track progress (e.g., "Step 5/11 complete")
- **Validate continuously** - Check compilation, tests, and coverage at each stage
- **Pause intelligently** - Stop on errors or ambiguity and wait for guidance
- **Handle complexity** - Support branching logic and error recovery

## Available Skills

### 1. `implement-backend-plan`

**Purpose**: Autonomously implement backend features (REST APIs or SQS Listeners) following a generated plan.

**Usage**:
```
implement-backend-plan @SCRUM-500_backend.md
```

**What it does**:
1. Reads and parses the implementation plan
2. Auto-selects appropriate agent (API or Listener developer)
3. Creates feature branch
4. Implements all steps sequentially (Domain → Application → Infrastructure → Presentation)
5. Verifies compilation after each step
6. Runs tests and validates 80%+ coverage
7. Updates technical documentation
8. Shows completion status with next steps

**Supports**:
- REST APIs (LaNacion.Core.Templates.Web.Api.Minimal)
- SQS Listeners (ln-SQSlstnr)
- Clean Architecture + CQRS + Event-Driven patterns
- Automatic agent selection based on plan

**Standards**:
- `ai-specs/specs/ln-susc-api-standards.mdc`
- `ai-specs/specs/ln-susc-listener-standards.mdc`

---

### 2. `implement-frontend-plan`

**Purpose**: Autonomously implement frontend features (React components) following a generated plan.

**Usage**:
```
implement-frontend-plan @SCRUM-501_frontend.md
```

**What it does**:
1. Reads and parses the implementation plan
2. Creates feature branch
3. Implements all steps sequentially (Components → State → Tests → Docs)
4. Installs dependencies if needed
5. Verifies compilation
6. Runs tests and validates 80%+ coverage
7. Validates accessibility (WCAG compliance)
8. Runs linter
9. Updates documentation
10. Shows completion status with next steps

**Supports**:
- React with TypeScript
- State management (Context, Redux, Zustand, etc.)
- Component testing
- Accessibility validation
- Responsive design

**Standards**:
- `ai-specs/specs/frontend-standards.mdc`

---

### 3. `scaffold-monorepo-backend-app`

**Purpose**: Scaffold a new backend app inside the Nx + .NET monorepo using the corporate app generator.

**Usage**:
```
scaffold-monorepo-backend-app
```

**What it does**:
1. Confirms whether the request is for an API or a listener
2. Uses the `add-template` generator flow
3. Verifies output under `apps/`
4. Verifies `.sln`, `project.json`, tests, Docker, `cdk/`, and VS Code integration
5. Applies the right backend standards after generation

**Supports**:
- Minimal APIs
- SQS listeners
- Monorepo-native app scaffolding

---

### 4. `scaffold-monorepo-lambda`

**Purpose**: Scaffold a new .NET 8 Lambda in the monorepo using the Lambda generator flow.

**Usage**:
```
scaffold-monorepo-lambda
```

**What it does**:
1. Validates Lambda naming and stack choice
2. Uses the `add-lambda` generator flow
3. Verifies app, tests, local runner, and CDK outputs
4. Checks `.sln` integration
5. Reviews known generator caveats before considering the scaffold complete

**Supports**:
- New Lambda stacks
- Lambdas added to existing stacks
- .NET 8 Lambda projects with local runner and CDK

---

### 5. `validate-monorepo-integration`

**Purpose**: Validate that a generated or modified monorepo artifact is correctly integrated into the workspace.

**Usage**:
```
validate-monorepo-integration
```

**What it does**:
1. Verifies placement under `apps/` or `libs/`
2. Checks `.sln` registration
3. Checks `project.json`, tests, and `cdk/`
4. Runs targeted build/test/synth validation
5. Reports hard failures and soft caveats separately

---

## Skills vs Commands

| Aspect | Commands | Skills |
|--------|----------|--------|
| **Invocation** | `/command-name` | Automatic by context |
| **Execution** | Manual, step-by-step | Autonomous, multi-step |
| **State** | Stateless | Maintains progress |
| **Validation** | Manual | Automatic at each step |
| **Error Handling** | User handles | Pauses and reports |
| **Complexity** | Simple, linear | Complex, with loops |

## When to Use Skills

✅ **Use skills for**:
- Multi-step implementations
- Features requiring validation at each stage
- Tasks that benefit from autonomous execution
- Complex workflows with error handling

❌ **Use commands for**:
- Simple, atomic operations
- Single-step tasks
- Quick actions without state

## Workflow Integration

### Current Workflow (with Skills)

```
User Story
    ↓ /enrich-us (command)
Enhanced Story
    ↓ /plan-backend-ticket (command)
Plan Generated
    ↓ implement-backend-plan (skill) ← AUTONOMOUS
Fully Implemented Feature
    ↓ (automatic)
Tests Passed + Docs Updated
```

### Benefits

1. **Autonomy**: Implements entire features without manual intervention
2. **Quality**: Validates compilation, tests, and coverage automatically
3. **Consistency**: Follows standards strictly at every step
4. **Resilience**: Pauses on errors instead of failing silently
5. **Transparency**: Shows progress and status continuously
6. **Documentation**: Updates docs automatically before completion
7. **Scaffolding Reuse**: Shared monorepo scaffolding logic can live in reusable skills

## Skill Execution Flow

### Backend Implementation Flow

```
Read Plan
    ↓
Auto-select Agent (API or Listener)
    ↓
Create Branch
    ↓
┌─────────────────────────────────┐
│ Loop: For each step in plan     │
│   - Implement code               │
│   - Verify syntax                │
│   - Mark complete                │
│   - Continue or pause            │
└─────────────────────────────────┘
    ↓
Verify Compilation (dotnet build)
    ↓
Run Tests (dotnet test)
    ↓
Validate Coverage (≥ 80%)
    ↓
Update Documentation
    ↓
Show Completion Status
    ↓
Optional: Commit & Push
```

### Frontend Implementation Flow

```
Read Plan
    ↓
Create Branch
    ↓
┌─────────────────────────────────┐
│ Loop: For each step in plan     │
│   - Implement component          │
│   - Apply TypeScript types       │
│   - Add accessibility            │
│   - Mark complete                │
│   - Continue or pause            │
└─────────────────────────────────┘
    ↓
Install Dependencies (if needed)
    ↓
Verify Compilation (npm build)
    ↓
Run Tests (npm test)
    ↓
Validate Coverage (≥ 80%)
    ↓
Validate Accessibility (WCAG)
    ↓
Run Linter (npm lint)
    ↓
Update Documentation
    ↓
Show Completion Status
    ↓
Optional: Commit & Push
```

## Guardrails

Both skills implement strict guardrails:

- **Never skip steps** - Execute in exact order
- **Pause on errors** - Don't guess or proceed blindly
- **Validate continuously** - Check compilation, tests, coverage
- **Follow standards** - Apply appropriate patterns (API/Listener/React)
- **Maintain quality** - 80% coverage minimum, accessibility compliance
- **Update docs** - Keep documentation current
- **Use English** - All code, comments, error messages

## Error Handling

Skills pause and report when encountering:

- Invalid or incomplete plan
- Missing prerequisites (git, .NET, Node.js)
- Unclear step requirements
- Compilation errors
- Test failures
- Coverage below 80%
- Accessibility violations
- Linting errors
- Missing dependencies

When paused, skills:
1. Report current progress
2. Describe the issue
3. Suggest options to resolve
4. Wait for user guidance

## Configuration

Skills are configured in:
- `.amazonq/skills/` - Amazon Q
- `.claude/skills/` - Claude
- `.cursor/skills/` - Cursor
- `.windsurf/skills/` - Windsurf
- `.opencode/skills/` - OpenCode
- `.gemini/skills/` - Gemini

Each AI tool loads skills from its respective directory.

## Compatibility

**Backend Skill Requirements**:
- .NET 6 SDK
- dotnet CLI
- git
- Plans generated by `lanacion-backend-planner`

**Frontend Skill Requirements**:
- Node.js
- npm or yarn
- git
- Plans generated by frontend planning agents

## Future Skills

Potential skills to add:

- `implement-database-migration` - Autonomous database schema updates
- `implement-integration-tests` - End-to-end test implementation
- `implement-deployment-pipeline` - CI/CD configuration
- `refactor-to-pattern` - Autonomous refactoring to architectural patterns

---

**Created by**: La Nación Development Team  
**Version**: 1.0.0  
**Last Updated**: 2025-01-22
