# La Nación Backend Development Guide

This guide provides step-by-step instructions for setting up the development environment for La Nación's backend systems using .NET 6/8, Clean Architecture, CQRS, and event-driven patterns.

## 🚀 Prerequisites

Ensure you have the following installed:
- **.NET 6.0 SDK** or higher
- **Node.js** (v16 or higher) and **npm** (for Nx monorepo tooling)
- **Git**
- **MySQL** (for database)
- **AWS CLI** (for Secrets Manager access)
- **Docker** (optional, for local database)

## 🏗️ Monorepo Setup

La Nación uses a hybrid Nx + .NET monorepo for orchestration and build management.

### 1. Clone the Repository

```bash
git clone https://github.com/jalessandrello-LN/ai-specs.git
cd ai-specs
```

### 2. Install Dependencies

```bash
# Install Nx CLI globally (if not already installed)
npm install -g nx

# Install monorepo dependencies
npm install
```

### 3. Initialize .NET Projects

The monorepo uses Nx generators to scaffold new projects:

```bash
# Generate a new API project
npm run generate:template

# Choose "LaNacion.Core.Templates.Web.Api.Minimal" when prompted
# Follow the wizard to configure project name and settings

# Generate a new SQS Listener project
npm run generate:template

# Choose "ln-SQSlstnr" when prompted
# Configure queue settings and project details
```

## 🔧 .NET Backend Setup

### Project Structure

Each backend project follows Clean Architecture:
```
[ProjectName]/
├── [ProjectName].Domain/           # Entities, Value Objects
├── [ProjectName].Domain.Events/    # Domain events
├── [ProjectName].Application/      # Commands, Queries, Handlers
├── [ProjectName].Application.Interfaces/  # Repository interfaces
├── [ProjectName].Repositories.SQL/ # Dapper implementations
├── [ProjectName].Api/              # Minimal API endpoints (APIs only)
└── [ProjectName].Workers/          # Hosted services (Listeners only)
```

### 4. Build and Run

```bash
# Build all .NET projects
dotnet build Ln.Sus.Monorepo.Template.sln

# Run a specific API project
cd apps/[ProjectName].Api
dotnet run

# Run a specific Listener project
cd apps/[ProjectName].Workers
dotnet run
```

## 🗄️ Database Configuration

La Nación backend uses MySQL with Dapper for data access.

### Connection Setup

**Never hardcode database credentials.** Use AWS Secrets Manager:

```json
// appsettings.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=your-mysql-server;Port=3306;Database=your-project-db;Uid={secret-username};Pwd={secret-password};"
  },
  "AWS": {
    "SecretsManager": {
      "DatabaseSecretName": "/lanacion/prod/database"
    }
  }
}
```

### Database Patterns

- **ORM**: Dapper (not Entity Framework)
- **Transactions**: Unit of Work pattern
- **Events**: Outbox Pattern for reliable publishing
- **Idempotency**: Duplicate message detection via `MensajesRecibidos` table

Example repository implementation:

```csharp
public class CustomerRepository : ICustomerRepository
{
    private readonly IContext _context;

    public async Task<Customer> GetByIdAsync(int id)
    {
        const string sql = "SELECT * FROM Customers WHERE Id = @Id";
        return await _context.Connection.QuerySingleOrDefaultAsync<Customer>(sql, new { Id = id });
    }
}
```

### Database Schema and Migrations

Database schema creation and evolution are handled outside the current agent implementation flow.

- Current backend agents implement business logic and data access code, but they do not generate `CREATE TABLE`, `ALTER TABLE`, index, or constraint DDL.
- Feature implementation assumes the database schema already exists with the required tables, columns, relationships, and indexes.
- Schema changes must be coordinated with DBA/DevOps and documented in `ai-specs/specs/data-model.md` and versioned migration scripts.
- A dedicated schema management guide is available at `ai-specs/specs/schema-management.md`.
- If a feature requires new fields, indexes, or relationships, add the schema change request to the implementation plan and apply it before deploying the service.
- Reference migration scripts live under `ai-specs/specs/db/migrations/mysql/` (example: `V001__lti_init.sql`).

### Manual Schema Change Flow

When a new feature introduces database changes, follow this manual process:

1. Identify required schema updates in the feature plan.
2. Document the new table/column/index requirements in `ai-specs/specs/data-model.md`.
3. Create a versioned MySQL migration script under `ai-specs/specs/db/migrations/mysql/` with the required `CREATE TABLE`, `ALTER TABLE`, or `CREATE INDEX` statements.
4. Review the script with DBA/DevOps for production compatibility, rollback strategy, and data preservation.
5. Apply the schema changes to the development database first and verify the application behavior.
6. Commit the migration script and reference it in the implementation plan or change artifact.
7. Deploy the schema changes before or alongside the application deployment, depending on the rollout strategy.

### Manual Migration Checklist

- [ ] Confirm the feature requires schema changes.
- [ ] Define table names, column names, data types, nullability, and default values.
- [ ] Define foreign-key relationships and indexes.
- [ ] Verify existing queries and repositories are compatible with new schema changes.
- [ ] Add the change to `data-model.md`.
- [ ] Provide rollback SQL or a downgrade path when possible.
- [ ] Test against local MySQL before production deployment.
- [ ] Review with DBA/DevOps.

### Example MySQL Migration Script

```sql
-- See the reference migration:
-- ai-specs/specs/db/migrations/mysql/V001__lti_init.sql
```

### Local Development Database

For local development, use MySQL with Docker:

```bash
# Run MySQL container
docker run --name mysql-dev -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=**** \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=*** \
  -e MYSQL_DATABASE=[nombre_proyecto] \
  -d mysql:8.0

# Connection string for local development
"Server=127.0.0.1;Port=3306;Database=[nombre_proyecto];Uid=user;Pwd=***;"
```

Or start manually with Docker Compose:

```bash
# docker-compose.yml
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      MYSQL_USER: 'user'
      MYSQL_PASSWORD: '***'
      MYSQL_ROOT_PASSWORD: '****'
      MYSQL_DATABASE: '[nombre_proyecto]'
    volumes:
      - mysql-data:/var/lib/mysql

volumes:
  mysql-data:
```

```bash
# Start the container
docker-compose up -d

# Verify MySQL is running
docker-compose ps
```

## 🤖 Agent & Skill Workflows

La Nación uses specialized AI agents for consistent development:

### Development Flow

1. **Enrich User Story** (Optional)
   ```bash
   /enrich-us HU-123
   ```

2. **Generate Implementation Plan**
   ```bash
   /plan-backend-ticket HU-123
   ```
   Creates `ai-specs/changes/HU-123_backend.md`

3. **Implement Features**
   ```bash
   /develop-backend @HU-123_backend.md
   ```
   Automatically selects API or Listener developer based on plan

> Note: Database schema changes are separate from the current agent workflows. Agents implement repository and application logic; schema creation, columns, relations and indexes must be provisioned independently or via external migration scripts.

### Available Agents

- **lanacion-backend-planner**: Creates detailed plans for APIs/Listeners
- **lanacion-api-developer**: Implements REST APIs with CQRS
- **lanacion-lstnr-developer**: Implements SQS event listeners
- **lanacion-nx-monorepo-developer**: Scaffolds new projects in monorepo

### Key Patterns

**APIs (Commands)**:
- Pattern: `cmd-{verb}-{entity}` (e.g., `cmd-create-subscription`)
- Validation: FluentValidation
- Events: Published via Outbox Pattern

**Listeners (Events)**:
- Pattern: `evt-{squad}-{entity}-{verb-past}` (e.g., `evt-susc-suscripcion-creada`)
- Idempotency: Check `MensajesRecibidos` table
- Queues: `{product}-{env}-sqs-{event}`

## 🧪 Testing

All projects require minimum **80% code coverage**.

### Unit Testing Setup

```bash
# Run tests for specific project
cd apps/[ProjectName].Tests
dotnet test

# Run all tests with coverage
dotnet test --collect:"XPlat Code Coverage"

# Generate coverage report
dotnet tool install -g dotnet-reportgenerator-globaltool
reportgenerator -reports:TestResults/**/*.xml -targetdir:coverage-report
```

### Testing Patterns

- **Framework**: xUnit
- **Assertions**: FluentAssertions
- **Mocking**: Moq
- **CQRS Testing**: Test commands/queries separately
- **Event Testing**: Verify events published via Outbox
- **Idempotency Testing**: Test duplicate message handling

Example test:

```csharp
[Fact]
public async Task CreateCustomerCommand_Should_Publish_CustomerCreated_Event()
{
    // Arrange
    var command = new CreateCustomerCommand { Name = "Test Customer" };

    // Act
    var result = await _mediator.Send(command);

    // Assert
    result.Should().BeOfType<CustomerCreated>();
    _outbox.Verify(x => x.AddAsync(It.IsAny<CustomerCreated>()), Times.Once);
}
```

## 📚 Standards & References

### Core Standards
- **[Base Standards](base-standards.mdc)**: Core principles and guidelines
- **[API Standards](ln-susc-api-standards.mdc)**: REST API implementation standards
- **[Listener Standards](ln-susc-listener-standards.mdc)**: SQS listener implementation standards
- **[Frontend Standards](frontend-standards.mdc)**: React/TypeScript standards

### Architecture Documentation
- **[ARQUITECTURA.md](../_docs de soporte/ARQUITECTURA.md)**: Complete architecture overview
- **[Coding Naming Conventions](../_docs de soporte/)**: Events, commands, and resource naming

### Development Workflow
- Use feature branches: `feature/HU-123-api` or `feature/HU-123-listener`
- Follow CQRS: Commands for writes, Queries for reads
- Implement event-driven architecture with Outbox Pattern
- Ensure idempotency in listeners
- Maintain 80%+ code coverage

For detailed implementation guidance, refer to the agent-generated plans and standards documents.

