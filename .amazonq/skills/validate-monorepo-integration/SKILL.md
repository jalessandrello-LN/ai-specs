---
name: validate-monorepo-integration
description: Validate that a generated or modified monorepo project is correctly integrated into the Nx + .NET workspace, including folder placement, solution registration, Nx targets, tests, CDK assets, VS Code hooks, and targeted build/test flows.
license: MIT
compatibility: Requires git, Nx workspace files, .NET toolchain relevant to the artifact
metadata:
  author: La Nación
  version: "1.0.0"
  references:
    - ai-specs/scr/template-nx-dotnet-desde-cero.md
    - ai-specs/scr/arq-monorepo.md
---

Validate that a project generated inside the monorepo was integrated correctly and did not leave the workspace in a half-configured state.

## When To Use

Use this skill after:
- scaffolding a new API
- scaffolding a new listener
- scaffolding a new Lambda
- making structural monorepo changes

## Validation Scope

Check the following areas:
- placement under `apps/` or `libs/`
- registration in the global `.sln`
- presence and coherence of `project.json`
- expected test project creation
- expected `cdk/` creation or updates
- expected VS Code integration
- targeted build/test/synth success

## Steps

1. Confirm the generated project lives in the correct monorepo path.
2. Confirm the expected folders exist.
3. Confirm the relevant `.csproj` entries are present in the global `.sln`.
4. Inspect `project.json` and verify expected targets exist.
5. Inspect `cdk/` for presence and basic consistency.
6. Inspect `.vscode/launch.json` and `.vscode/tasks.json` when the generator is expected to touch them.
7. Run the smallest relevant validation commands first.
8. Report hard failures and soft caveats separately.

## Targeted Validation Commands

For apps:

```bash
npx nx run <ProjectName>:build
npx nx run <ProjectName>:test
```

For stacks with infrastructure:

```bash
npx nx run <ProjectName>:synth --configuration=dev
```

For broader .NET validation:

```bash
dotnet build
dotnet test
```

## Output

Always report:
- project path
- integration status of `.sln`
- integration status of `project.json`
- integration status of `tests/`
- integration status of `cdk/`
- validation commands run
- known caveats that still require review

## Guardrails

- Distinguish between generator bugs and local misconfiguration.
- Do not claim the project is ready until integration checks pass.
- If the generator partially succeeded, report the exact missing pieces.
- Prefer targeted validation before workspace-wide validation.

