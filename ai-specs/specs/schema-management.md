# Schema Management Guide

This document explains how to manage database schema changes for backend services.

## Purpose

This guide separates responsibilities between:

- **Feature delivery (agents/developers)**: application logic, handlers, repositories, tests, and docs
- **Schema management (DBA/DevOps)**: tables/columns, constraints, indexes, versioned migrations, and safe rollout/rollback

## Responsibilities

### Agents / Developers

Agents and feature developers typically implement:

- business logic (CQRS handlers, validators)
- data access code (Dapper repositories)
- transactional patterns (Unit of Work, Outbox)
- documentation updates (API spec, data model)

Agents and feature developers should not decide production rollout order or schema deployment strategy.

### DBA / DevOps

Schema management includes:

- schema versioning and rollout strategy per environment
- safe execution (online changes, locking considerations)
- rollback / downgrade plan (when feasible)
- performance review (indexes, query plans)

## When schema changes are required

Any feature that:

- adds a new entity/table
- adds/removes columns
- changes data types or nullability
- changes relationships or cardinality
- requires new indexes for performance

## Migration conventions (MySQL)

This repository includes a **reference** migration set under:

- `ai-specs/specs/db/migrations/mysql/`

Naming convention:

- `V###__<short_description>.sql` (e.g., `V001__lti_init.sql`)

## Manual schema change flow

1. Identify required schema changes in the feature plan.
2. Update `ai-specs/specs/data-model.md` to reflect the intended data model.
3. Create/adjust a versioned migration script under `ai-specs/specs/db/migrations/mysql/`.
4. Review the script with DBA/DevOps for compatibility, rollout, and rollback strategy.
5. Apply the migration to a local development database and validate behavior.
6. Ensure repositories/queries and tests are compatible with the new schema.
7. Reference the migration in the change artifact (plan/tasks) and include it in the same PR.
8. Deploy the schema before or alongside the application deployment (per DBA/DevOps guidance).

## Schema validation checklist

- [ ] The feature really requires schema changes.
- [ ] Tables/columns/types/nullability/defaults are defined.
- [ ] Relationships and foreign keys are documented.
- [ ] Indexes for hot paths are included.
- [ ] Existing queries/repositories remain compatible.
- [ ] Migration impact on existing data is assessed.
- [ ] Rollback/downgrade strategy is defined when possible.
- [ ] Script is tested locally before production rollout.
- [ ] DBA/DevOps reviewed and approved the script.

## Reference migration

- `ai-specs/specs/db/migrations/mysql/V001__lti_init.sql` creates the reference schema matching `ai-specs/specs/data-model.md`.
