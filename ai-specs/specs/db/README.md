# Database Reference Schema (MySQL)

This folder contains **reference** MySQL migration scripts that match the data model documentation in `ai-specs/specs/data-model.md`.

## Conventions

- Migrations live under `ai-specs/specs/db/migrations/mysql/`
- Naming: `V###__<short_description>.sql`

## Apply locally (Docker + MySQL)

If you have a running MySQL container with the `mysql` client available inside it, you can apply migrations via `docker exec`.

Example (create a new empty database and apply `V001`):

```bash
# 1) Create database
docker exec <mysql-container> mysql -u root -p<password> -e "CREATE DATABASE IF NOT EXISTS <db_name>;"

# 2) Apply migration
cat ai-specs/specs/db/migrations/mysql/V001__lti_init.sql | docker exec -i <mysql-container> mysql -u root -p<password> <db_name>

# 3) Verify
docker exec <mysql-container> mysql -u root -p<password> -D <db_name> -e "SHOW TABLES;"
```

Notes:

- Do not commit credentials. Prefer environment variables or a secrets manager for real projects.
- For rollout/rollback guidance, see `ai-specs/specs/schema-management.md`.
