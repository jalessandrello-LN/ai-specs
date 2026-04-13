---
name: scaffold-monorepo-lambda
description: Scaffold a new .NET 8 Lambda in the Nx monorepo, either inside an existing CDK stack or as a new stack, including app, tests, local runner, CDK integration, and solution registration.
license: MIT
compatibility: Requires Node.js 20, npm, .NET SDK 8, git, AWS-oriented CDK toolchain
metadata:
  author: La Nación
  version: "1.0.0"
  references:
    - ai-specs/scr/template-nx-dotnet-desde-cero.md
    - ai-specs/scr/arq-monorepo.md
  generators:
    - add-lambda
  outputs:
    - apps/<StackName>/app/<LambdaName>/
    - apps/<StackName>/tests/<LambdaName>.Tests/
    - apps/<StackName>/local/<LambdaName>.Local/
---

Scaffold a Lambda inside the monorepo using the existing Nx generator and then verify the generated stack integration carefully.

## When To Use

Use this skill when the user needs:
- A new Lambda function
- A Lambda added to an existing stack
- A new stack with Lambda app, tests, local runner, and CDK wiring

Do not use this skill for Minimal APIs or listeners. Use `scaffold-monorepo-backend-app` instead.

## Inputs To Confirm

- `cdkOption`
- `cdkName`
- `name`
- `memorySize`
- `orderRelease`

## Naming Rule

The `name` input must end with `.lambda`.

Example:
- `LN.Sus.Algo.Procesador.lambda`

The generator normalizes it into:
- main project: `LN.Sus.Algo.Procesador.Lambda`
- tests project: `LN.Sus.Algo.Procesador.Lambda.Tests`
- local runner: `LN.Sus.Algo.Procesador.Lambda.Local`

## Preconditions

Before scaffolding, verify:
- Node.js 20 is available
- npm is available
- .NET SDK 8 is available
- git is available
- `package.json` exists
- `nx.json` exists
- the global solution exists

If a prerequisite is missing, stop and report the blocker.

## Generation Path

Primary command:

```bash
npm run generate:lambda
```

Underlying generator:

```bash
nx g @ln/generators:add-lambda --interactive
```

## Steps

1. Confirm whether the Lambda belongs to an existing stack or a new one.
2. Validate that the requested name ends with `.lambda`.
3. Confirm memory and `orderRelease`.
4. Run `generate:lambda`.
5. Verify the generated folders:
   - `app/`
   - `tests/`
   - `local/`
   - `cdk/` when creating a new stack
6. Verify that generated `.csproj` files were added to the global `.sln`.
7. Review `cdk/src/config/appSettings.json`.
8. Review `cdk/src/model/stackModel.ts`.
9. Review the generated Nx targets before trusting the scaffold.

## Expected Structure

```text
apps/<StackName>/
  app/<LambdaName>/
  tests/<LambdaName>.Tests/
  local/<LambdaName>.Local/
  cdk/
  project.json
```

## Known Caveats

Treat the generated result as usable but not final until inspected.

Pay special attention to:
- circular dependency between `build` and `build:package`
- references to nonexistent `build:net`
- incomplete or brittle CDK file updates

If the generator leaves inconsistent targets, fix only the minimum required and report the remaining template debt clearly.

## Validation

Prefer targeted validation first:

```bash
npx nx run <StackName>:build
npx nx run <StackName>:test
```

When CDK is involved:

```bash
npx nx run <StackName>:synth --configuration=dev
```

Then expand if needed:

```bash
dotnet build
dotnet test
```

## Guardrails

- Do not bypass the generator unless it is demonstrably broken.
- Keep Lambdas under `apps/<StackName>/`.
- Preserve `.sln` consistency.
- Verify `project.json` targets before relying on them.
- Keep CDK co-located under the stack.
- Report generator inconsistencies explicitly instead of silently assuming they are harmless.

