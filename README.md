# AI Specifications & Development Rules

This repository contains a comprehensive set of development rules, standards, and AI agent configurations designed to work seamlessly with multiple AI coding copilots. The setup is portable and can be imported into any project to provide consistent, high-quality AI-assisted development.

It's highly recommended to be used along with Spec-Driven Development frameworks like [OpenSpec](https://github.com/Fission-AI/OpenSpec)

## 📁 Repository Structure

```
.
├── ai-specs/                     # Canonical source (single source of truth)
│   ├── specs/                    # Standards (rules that agents follow)
│   ├── .agents/                  # Agent definitions (roles)
│   ├── .commands/                # Commands (prompts/workflows)
│   ├── .skills/                  # Skills documentation
│   └── changes/                  # Generated plans (e.g., HU-10_backend.md)
│
├── openspec/                     # OpenSpec workspace (spec-driven development)
│   ├── config.yaml               # Project context + per-artifact rules
│   └── changes/                  # OpenSpec change artifacts (and archive)
│
├── .agent/                       # Multi-copilot adapter layer (points to `ai-specs/`)
│   ├── agents/                   # Pointer files → `ai-specs/.agents/*`
│   ├── commands/                 # Pointer files → `ai-specs/.commands/*`
│   ├── skills/                   # Skill definitions (includes OpenSpec skills)
│   ├── specs/                    # Specs exposed to tools
│   └── workflows/                # OpenSpec workflows (opsx-*)
│
├── .claude/ .codex/ .cursor/ ... # Tool-specific mirrors of `.agent/`
├── .github/                      # GitHub Copilot prompts/specs/skills
├── links.ps1                     # Helper: sync `.agent/` into tool folders (creates `.agent_backups/`)
│
├── AGENTS.md                     # Generic agent configuration
├── CLAUDE.md                     # Claude-specific configuration
├── codex.md                      # GitHub Copilot/Codex configuration
└── GEMINI.md                     # Gemini-specific configuration
```

For a complete directory map, see `STRUCTURE-GUIDE.md`.

## 🤖 Multi-Copilot Support

This repository avoids duplication by keeping the canonical content under `ai-specs/` and exposing it through a lightweight adapter layer (`.agent/` + tool folders like `.claude/`, `.codex/`, `.cursor/`).

In this repo the adapters are plain **pointer files** (not symlinks) that reference `ai-specs/...` paths. Tool folders can be mirrored from `.agent/` using `links.ps1`.

- **`AGENTS.md`** → Generic agent rules (works with most copilots)
- **`CLAUDE.md`** → Optimized for Claude/Cursor
- **`codex.md`** → Optimized for GitHub Copilot/Codex
- **`GEMINI.md`** → Optimized for Google Gemini

All these files reference the same core rules in `ai-specs/specs/base-standards.mdc`, ensuring consistency across different AI tools while allowing copilot-specific customizations.

### Why This Approach?

✅ **Single Source of Truth**: Core rules maintained in one place (`base-standards.mdc`)  
✅ **Copilot Compatibility**: Each AI tool finds its configuration using its preferred naming convention  
✅ **Zero Configuration**: Import into a new project and it works immediately  
✅ **Easy Updates**: Update rules once, all copilots benefit  
✅ **Portable**: Copy this structure to any project  

## 🚀 Quick Start

### 1. Import Into Your Project

```bash
# Clone or copy this repository into your project
cp -r LIDR-ai-specs/* your-project/

# The AI copilot will automatically detect the relevant configuration file
```

### 2. Verify Configuration

Your AI copilot will automatically load:
- **Claude/Cursor**: `CLAUDE.md` → `ai-specs/specs/base-standards.mdc`
- **GitHub Copilot**: `codex.md` → `ai-specs/specs/base-standards.mdc`
- **Gemini**: `GEMINI.md` → `ai-specs/specs/base-standards.mdc`

All paths and rules are configured to work seamlessly without manual adjustments.

## 💡 Usage: Autonomous Development Workflow

The most efficient way to work with this setup is using an autonomous workflow with **AI Skills**:

### What are Skills?

Skills are advanced AI capabilities that enable **autonomous, multi-step implementation** with:
- ✅ **Automatic execution** of all implementation steps
- ✅ **Continuous validation** (compilation, tests, coverage)
- ✅ **Intelligent pausing** on errors or ambiguity
- ✅ **State management** (tracks progress: "Step 5/11 complete")
- ✅ **Automatic documentation** updates

### Workflow Overview

### Step 1: Enrich the User Story (Optional)

If your user story lacks detail or acceptance criteria, use the **`enrich-us`** command to enhance it:

```
/enrich-us HU-10
```

This command analyzes the user story and generates:
- Detailed acceptance criteria
- Edge cases and validation rules
- Technical considerations
- Testing scenarios

**Note**: Skip this step if your user story already has sufficient depth and clear requirements.

### Step 2: Plan the Feature

Use **`plan-ticket`** commands to generate detailed implementation plans:

```
/plan-backend-ticket HU-10
```

or

```
/plan-frontend-ticket HU-15
```

This creates a comprehensive, step-by-step implementation plan in `ai-specs/changes/`.

### Step 3: Implement the Feature (AUTONOMOUS)

Use **AI Skills** for autonomous implementation:

```
implement-backend-plan @HU-10_backend.md
```

or

```
implement-frontend-plan @HU-15_frontend.md
```

**The AI will autonomously**:
1. Read and parse the complete plan
2. Auto-select the appropriate agent (API or Listener for backend)
3. Create the feature branch
4. **Implement ALL steps in a loop** (Domain → Application → Infrastructure → Presentation)
5. Verify compilation after each step
6. Run tests and validate 80%+ coverage
7. Update technical documentation automatically
8. Show completion status
9. Optionally commit and push

**Pauses intelligently** if:
- Compilation errors occur
- Tests fail or coverage is below 80%
- Requirements are unclear
- Any blocker is encountered

### Example: Implementing HU-10 (Position Update Feature)

#### Step 1: Enrich the User Story (Optional)

**You say:**
```
/enrich-us HU-10
```

**AI enhances** the user story with detailed acceptance criteria and technical considerations (skip if already detailed).

#### Step 2: Generate the Plan

**You say:**
```
/plan-backend-ticket HU-10
```

**AI generates:**
- Analyzes the ticket requirements
- Creates `ai-specs/changes/HU-10_backend.md` with:
  - Architecture context
  - Step-by-step implementation instructions
  - Complete test specifications (validation, service, controller layers)
  - API documentation updates
  - Validation rules
  - Error handling strategies

#### Step 3: Implement Following the Plan (AUTONOMOUS)

**You say:**
```
implement-backend-plan @HU-10_backend.md
```

**AI executes autonomously:**
1. Reads the plan and detects backend type (API or Listener)
2. Adopts role: `lanacion-api-developer` or `lanacion-lstnr-developer`
3. Creates the feature branch defined by the plan (e.g., `feature/HU-10-api` or `feature/HU-10-listener`)
4. **Implements all steps in loop:**
   - Step 1/N: Domain ✓
   - Step 2/N: Application ✓
   - Step 3/N: Infrastructure ✓
   - Step 4/N: Presentation ✓
   - Step 5/N: Tests ✓
5. Verifies compilation (e.g., `dotnet build`) ✓
6. Runs tests (e.g., `dotnet test`) and validates coverage (≥ 80%) ✓
7. Updates documentation (e.g., `ai-specs/specs/data-model.md`) ✓
8. Shows completion status
9. Optionally commits and pushes

### 📝 Demo Enriched User Story

Check out **`ai-specs/changes/HU-10-Position-Update.md`** for a complete example of what an enriched user story looks like. This comprehensive document includes:

- **User Story**: Clear description with persona, goal, and benefit
- **Technical Specification**: Complete technical implementation details
- **API Endpoint Documentation**: Request/response formats, status codes, and error handling
- **Database Fields**: All updateable fields with validation rules
- **Validation Rules**: Server-side and client-side validation requirements
- **Security Requirements**: Authentication, authorization, and input sanitization needs
- **Testing Requirements**: Unit tests, integration tests, and manual testing scenarios
- **Acceptance Criteria**: Clear, testable acceptance criteria for each requirement
- **Non-Functional Requirements**: Usability, performance, reliability, and security standards
- **Definition of Done**: Complete checklist for feature completion

This enriched document transforms a simple user story into a detailed specification that provides all the context needed for autonomous implementation by AI agents or developers.

### 📋 Demo Implementation Plan

Check out **`ai-specs/changes/HU-10_backend.md`** for a complete example of what a feature implementation plan looks like. This comprehensive plan includes:

- **Architecture Context**: Layers, components, and dependencies
- **Step-by-Step Instructions**: Validation → Service → Controller → Routes → Tests → Documentation
- **Complete Code Examples**: Full implementations for each layer
- **Comprehensive Test Specifications**: 90%+ coverage requirements with example tests
- **Error Handling**: HTTP status codes, error messages, and response formats
- **Business Rules**: Validation requirements and constraints
- **Testing Checklist**: Unit, manual, integration, and regression tests

This plan demonstrates how detailed and actionable the generated plans are, enabling autonomous implementation by AI agents.

## 📖 Core Development Rules

All development follows principles defined in `ai-specs/specs/base-standards.mdc`:

### Key Principles

1. **Small Tasks, One at a Time**: Baby steps, never skip ahead
2. **Test-Driven Development (TDD)**: Write failing tests first
3. **Type Safety**: Prefer strongly typed code and strict compilation settings (e.g., C#, TypeScript)
4. **Clear Naming**: Descriptive variables and functions
5. **Language Standards**: Follow `ai-specs/specs/base-standards.mdc`
6. **80%+ Test Coverage**: Comprehensive testing across all layers (enforced by skills)
7. **Incremental Changes**: Focused, reviewable modifications

### Specific Standards

- **API Backend Standards**: `ai-specs/specs/ln-susc-api-standards.mdc`
  - *REST API development with .NET 6, Clean Architecture, CQRS, and Event Publishing*
- **Listener Backend Standards**: `ai-specs/specs/ln-susc-listener-standards.mdc`
  - *SQS event processing with .NET 6, idempotency, and event-driven patterns*
  - API development patterns
  - Database best practices
  - Security guidelines
  - Testing requirements

- **Frontend Standards**: `ai-specs/specs/frontend-standards.mdc`
  - React component patterns
  - UI/UX guidelines
  - State management
  - Component testing

- **Documentation Standards**: `ai-specs/specs/documentation-standards.mdc`
  - Technical documentation structure
  - API documentation (OpenAPI)
  - Code documentation
  - Maintenance guidelines

## 🎯 Benefits

### For Developers
- ✅ **Consistent Code Quality**: AI follows the same standards every time
- ✅ **Comprehensive Testing**: Automatic 80%+ coverage across all layers
- ✅ **Complete Documentation**: API specs updated automatically
- ✅ **Faster Onboarding**: New team members reference the same rules
- ✅ **Reduced Review Time**: Code follows established patterns
- ✅ **Autonomous Implementation**: Skills implement entire features without manual intervention

### For Teams
- ✅ **Copilot Flexibility**: Team members can use their preferred AI tool
- ✅ **Knowledge Preservation**: Standards documented, not in people's heads
- ✅ **Quality Consistency**: Same standards regardless of who (or what) writes code
- ✅ **Easier Code Reviews**: Clear expectations and patterns
- ✅ **Scalable Practices**: Standards scale with the team

### For Projects
- ✅ **Maintainable Codebase**: Clean architecture and clear separation of concerns
- ✅ **Production-Ready Code**: TDD, error handling, and validation built-in
- ✅ **Living Documentation**: API specs and data models always current
- ✅ **Faster Feature Development**: Autonomous AI implementation from plans
- ✅ **Lower Technical Debt**: Best practices enforced from day one

## 🔧 Customization

### Adapting to Your Project

1. **Update technical context**: Find the different files in `ai-specs/specs` and modify core principles, coding standards, business rules and technical documentation to match your needs:
   - backend/frontend/testing/documentation standards
   - installation guide
   - data model
   - API docs
   - ...
2. **Adapt agents in `ai-specs/.agents`**: Adjust agent definitions to your project's roles and workflows
3. **Extend Commands**: Define battle-tested prompts into commands in `ai-specs/.commands` 
4. **Link Resources**: Reference your project's specific documentation or tasks using MCPs
5. **Keep the adapter layer consistent**: Add/update pointer files in `.agent/` and (if needed) run `links.ps1` to mirror them into tool-specific folders

### Maintaining Standards

- **Single Source of Truth**: Always update `base-standards.mdc` first
- **Version Control**: Track changes to standards like code
- **Team Review**: Standards changes should be reviewed like pull requests
- **Documentation**: Keep examples current with actual implementation

## 🤖 AI Skills (NEW)

This repository includes **autonomous AI skills** that enable multi-step implementation without manual intervention:

### Available Skills

1. **`implement-backend-plan`** - Autonomous backend implementation
   - Supports REST APIs and SQS Listeners
   - Auto-selects appropriate agent (API or Listener developer)
   - Implements all steps in loop with validation
   - Runs tests and validates 80%+ coverage
   - Updates documentation automatically

2. **`implement-frontend-plan`** - Autonomous frontend implementation
   - Supports React with TypeScript
   - Implements components with state management
   - Runs tests and validates 80%+ coverage
   - Validates accessibility (WCAG)
   - Updates documentation automatically

### Skills vs Commands

| Aspect | Commands | Skills |
|--------|----------|--------|
| **Execution** | Manual, step-by-step | Autonomous, multi-step |
| **State** | Stateless | Maintains progress |
| **Validation** | Manual | Automatic at each step |
| **Testing** | Manual | Automatic with coverage |
| **Documentation** | Manual | Automatic updates |

For more details, see `ai-specs/.skills/README.md`

---

## 📚 Technical context

### Reference Examples

The following files are included as **reference examples**. You should create your own versions tailored to your specific project:

- **API Specification**: `ai-specs/specs/api-spec.yml` (OpenAPI 3.0 format)
  - *Create your own API spec documenting your project's endpoints*
- **Data Models**: `ai-specs/specs/data-model.md` (Database schemas, domain models)
  - *Document your database structure and domain entities*
- **Development Guide**: `ai-specs/specs/development_guide.md` (Setup, workflows)
  - *Write setup instructions specific to your tech stack*


## 🤝 Contributing

When contributing to the standards:

1. Update `base-standards.mdc` (single source of truth)
2. Test with multiple AI copilots to ensure compatibility
3. Update examples in `changes/` folder if needed
4. Document breaking changes clearly
5. Follow the same standards you're defining!
