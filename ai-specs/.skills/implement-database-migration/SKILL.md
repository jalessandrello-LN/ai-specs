---
name: implement-database-migration
description: Design and apply database schema migrations for MySQL-based backend projects, including versioned DDL, rollback guidance, and schema validation.
license: MIT
compatibility: Requires .NET 6, dotnet CLI, git, MySQL
metadata:
  author: La Nación
  version: "1.0.0"
  standards:
    - ai-specs/specs/base-standards.mdc
    - ai-specs/specs/ln-susc-api-standards.mdc
  agents:
    - lanacion-backend-planner
---

Implement database schema migration support for backend features using a controlled, versioned workflow.

## Scope

This skill is responsible for:

- validating that schema changes are required for a feature
- creating or updating MySQL migration scripts
- defining rollback or downgrade paths
- ensuring schema changes are documented in `ai-specs/specs/data-model.md`
- integrating schema updates with the feature implementation plan

## Expected Workflow

1. Read the feature plan and identify schema changes.
2. Generate or validate a MySQL migration script.
3. Add schema documentation to `ai-specs/specs/data-model.md`.
4. Coordinate with DBA/DevOps for production rollout.
5. Mark the schema scripts as part of the change artifact.

## Notes

- This skill is designed to be automatable, but it can also be followed manually.
- Reference migration scripts live under `ai-specs/specs/db/migrations/mysql/` (example: `V001__lti_init.sql`).
- For the schema management process and validation checklist, see `ai-specs/specs/schema-management.md`.
