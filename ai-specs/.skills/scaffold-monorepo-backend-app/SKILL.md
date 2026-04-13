---
name: scaffold-monorepo-backend-app
description: Scaffold a new Nx + .NET backend application in the monorepo using the corporate template flow. Supports Minimal APIs and SQS listeners, integrates the generated app into apps/, the global .sln, project.json, tests, Docker, CDK, and VS Code.
license: MIT
compatibility: Requires Node.js 20, npm, .NET SDK 6, git, NuGet feed access
metadata:
  author: La Nación
  version: "1.0.0"
  references:
    - ai-specs/scr/template-nx-dotnet-desde-cero.md
    - ai-specs/scr/arq-monorepo.md
    - ai-specs/specs/ln-susc-api-standards.mdc
    - ai-specs/specs/ln-susc-listener-standards.mdc
  generators:
    - add-template
  outputs:
    - apps/<ProjectName>/
---

Scaffold a new backend app inside the monorepo using the existing Nx generator and the corporate .NET templates.

## When To Use

Use this skill when the user needs:
- A new Minimal API
- A new SQS listener
- A new backend app integrated into the Nx monorepo

Do not use this skill for standalone Lambdas. Use `scaffold-monorepo-lambda` instead.

## Inputs To Confirm

- `name`
- `templateType`
- `httpPort`
- `httpsPort`
- `orderRelease`

`templateType` must map to one of:
- `ln-minWebApi` for APIs
- `ln-SQSlstnr` for listeners

## Preconditions

Before scaffolding, verify:
- Node.js 20 is available
- npm is available
- .NET SDK 6 is available
- git is available
- `package.json` exists at repo root
- `nx.json` exists at repo root
- `NuGet.config` exists at repo root
- the global solution exists
- corporate template/NuGet access is available

If a prerequisite is missing, stop and report the exact blocker.

## Generation Path

Primary command:

```bash
npm run generate:template
```

Underlying generator:

```bash
nx g @ln/generators:add-template --interactive
```

## Steps

1. Determine whether the request is for an API or a listener.
2. Map the artifact to the correct `templateType`.
3. Confirm or derive a valid project name.
4. Confirm local ports and `orderRelease`.
5. Run `generate:template`.
6. Inspect the generated app under `apps/<ProjectName>/`.
7. Verify that all generated `.csproj` files were added to the global `.sln`.
8. Verify that `project.json` exists and includes standard Nx targets.
9. Verify that `tests/`, `cdk/`, `Dockerfile`, and local config files exist.
10. Apply the proper standards after generation:
    - API -> `ln-susc-api-standards.mdc`
    - Listener -> `ln-susc-listener-standards.mdc`

## Expected Structure

```text
apps/<ProjectName>/
  project.json
  Dockerfile
  .dockerignore
  cdk/
  src/
  tests/
```

The internal `src/` shape depends on the selected corporate .NET template.

## Post-Generation Checks

Always validate:
- The generated app lives under `apps/`
- The app has a valid `project.json`
- The app is present in the global `.sln`
- Tests were created
- `cdk/` exists
- VS Code integration was updated when expected

## Known Caveats

- `add-template` is hybrid: it uses Nx plus shell side effects.
- A failure mid-run can leave the workspace partially integrated.
- The safest recovery is to inspect `apps/<ProjectName>/`, `.sln`, `.vscode`, and generated configs before retrying.

## Validation

Prefer targeted validation first:

```bash
npx nx run <ProjectName>:build
npx nx run <ProjectName>:test
```

Then expand if needed:

```bash
dotnet build
dotnet test
```

If infrastructure matters:

```bash
npx nx run <ProjectName>:synth --configuration=dev
```

## Guardrails

- Do not handcraft the app structure if the generator can create it.
- Do not place app code under `ai-specs/` or `openspec/`.
- Keep the app under `apps/`.
- Preserve `.sln` consistency.
- Preserve Nx target consistency in `project.json`.
- For listeners, verify queue-oriented configuration and worker registration patterns.
- For APIs, verify endpoint and REST conventions after generation.

