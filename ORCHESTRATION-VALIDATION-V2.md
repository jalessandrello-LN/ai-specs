# Validación de Orquestación de Agentes v2 - Con Monorepo

## 🎯 Objetivo

Validar que la arquitectura de orquestación funciona correctamente con los cambios de monorepo (`npm run generate:template` y `lanacion-nx-monorepo-developer`) y decide adecuadamente entre APIs y Listeners.

---

## 📋 Cambios Detectados en Agentes

### lanacion-api-developer
```diff
+ ## Template Installation
+ For new APIs inside the monorepo, do **not** scaffold with direct `dotnet new` commands.
+ Use the monorepo generator flow:
+ ```bash
+ npm run generate:template
+ ```
+ If the request is primarily scaffolding or workspace integration, route first through 
+ `lanacion-nx-monorepo-developer` and the `scaffold-monorepo-backend-app` skill
```

### lanacion-lstnr-developer
```diff
+ ## Template Installation
+ For new listeners inside the monorepo, do **not** scaffold with direct `dotnet new` commands.
+ Use the monorepo generator flow:
+ ```bash
+ npm run generate:template
+ ```
+ If the request is primarily scaffolding or workspace integration, route first through 
+ `lanacion-nx-monorepo-developer` and the `scaffold-monorepo-backend-app` skill
```

---

## 🎯 Simulación 1: API REST - Crear Endpoint de Productos

### Ticket: SCRUM-700

**Descripción**: Como usuario del sistema, quiero crear productos mediante un endpoint REST para gestionar el catálogo de productos.

**Criterios de Aceptación**:
- Endpoint POST `/api/v1/products`
- Validar datos (nombre, precio, categoría)
- Guardar en base de datos
- Publicar evento `evt-catalog-product-created`
- Retornar 201 Created con ID del producto

---

### Fase 1: Análisis del Planner

**Agente**: `lanacion-backend-planner`

#### Análisis de Requisitos
```
📝 Leyendo ticket SCRUM-700...

Keywords detectados:
✓ "endpoint REST" → Indica API
✓ "POST /api/v1/products" → Confirma REST API
✓ "Retornar 201 Created" → HTTP response
✗ NO menciona "SQS", "queue", "listener"
✗ NO menciona "consumir eventos"

🎯 DECISIÓN: Backend Type = API
📚 Standards: ln-susc-api-standards.mdc
```

#### Razonamiento del Planner
```
Patrón identificado:
- Request HTTP → Validación → Procesamiento → Respuesta HTTP → Publicar Evento

Características:
✓ Sincrónico (request/response)
✓ Requiere HTTP status codes
✓ Publica eventos (no los consume)
✓ Necesita endpoint REST

Conclusión: REST API con CQRS y Event Publishing (Outbox Pattern)
```

#### Plan Generado
**Archivo**: `ai-specs/changes/SCRUM-700_backend.md`

```markdown
# Backend Implementation Plan: SCRUM-700 Create Product API

## Overview
Create a REST API endpoint to manage product catalog with validation and event publishing.

**Backend Type**: API
**Template**: LaNacion.Core.Templates.Web.Api.Minimal
**Architecture**: Clean Architecture + CQRS + Event Publishing
**Monorepo Integration**: Yes (use npm run generate:template)

## Architecture Context

### Layers Involved
- **Domain**: Product entity
- **Application**: CreateProductCommand, Handler, Validator
- **Infrastructure**: ProductRepository
- **Presentation**: ProductEndpoints

### Standards Reference
`ai-specs/specs/ln-susc-api-standards.mdc`

### Monorepo Considerations
⚠️ **IMPORTANT**: This is a new API in the monorepo.

**Scaffolding Required**:
1. Use `npm run generate:template` to scaffold the API structure
2. Choose "Minimal API" path during interactive flow
3. Let generator register app under `apps/` and update `.sln`, `project.json`, `tests/`, `cdk/`

**Alternative**: If scaffolding is the primary need, route through:
- Agent: `lanacion-nx-monorepo-developer`
- Skill: `scaffold-monorepo-backend-app`
- Then return to this agent for business logic implementation

## Implementation Steps

### Step 0: Scaffold Monorepo App (if new)

**Action**: Create new API app in monorepo

**Commands**:
```bash
npm run generate:template
# Interactive prompts:
# - Type: API
# - Name: products-api
# - Template: Minimal API
```

**Verification**:
- [ ] App created under `apps/products-api/`
- [ ] `.sln` updated
- [ ] `project.json` updated
- [ ] Tests folder created
- [ ] CDK configuration added

**Notes**: Skip this step if app already exists in monorepo.

---

### Step 1: Create Feature Branch

**Branch Naming**: `feature/SCRUM-700-api`

**Commands**:
```bash
git checkout main
git pull origin main
git checkout -b feature/SCRUM-700-api
```

---

### Step 2: Domain Entity

**File**: `apps/products-api/src/Domain/Entities/Product.cs`

**Implementation**:
```csharp
namespace ProductsApi.Domain.Entities;

public class Product
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
    public string Category { get; set; }
    public DateTime CreatedAt { get; set; }
    public string CreatedBy { get; set; }
}
```

---

### Step 3: CQRS Command

**File**: `apps/products-api/src/Application/Commands/CreateProductCommand.cs`

**Implementation**:
```csharp
using MediatR;

namespace ProductsApi.Application.Commands;

public record CreateProductCommand(
    string Name,
    decimal Price,
    string Category
) : IRequest<Guid>;
```

---

### Step 4: Validator

**File**: `apps/products-api/src/Application/Validators/CreateProductCommandValidator.cs`

**Implementation**:
```csharp
using FluentValidation;

namespace ProductsApi.Application.Validators;

public class CreateProductCommandValidator : AbstractValidator<CreateProductCommand>
{
    public CreateProductCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Product name is required")
            .MaximumLength(200).WithMessage("Product name cannot exceed 200 characters");
        
        RuleFor(x => x.Price)
            .GreaterThan(0).WithMessage("Price must be greater than zero");
        
        RuleFor(x => x.Category)
            .NotEmpty().WithMessage("Category is required")
            .Must(c => new[] { "Electronics", "Clothing", "Food" }.Contains(c))
            .WithMessage("Invalid category");
    }
}
```

---

### Step 5: Handler

**File**: `apps/products-api/src/Application/Handlers/CreateProductHandler.cs`

**Implementation**:
```csharp
using MediatR;
using ProductsApi.Domain.Entities;
using ProductsApi.Application.Interfaces;
using LaNacion.Core.Infraestructure.Data.Relational;
using LaNacion.Core.Infraestructure.Events.Publisher;

namespace ProductsApi.Application.Handlers;

public class CreateProductHandler : IRequestHandler<CreateProductCommand, Guid>
{
    private readonly IUnitOfWork _uoW;
    private readonly IProductRepository _repo;
    private readonly IMessagePublisher _publisher;
    private readonly ILogger<CreateProductHandler> _logger;

    public CreateProductHandler(
        IUnitOfWork uoW,
        IProductRepository repo,
        IMessagePublisher publisher,
        ILogger<CreateProductHandler> logger)
    {
        _uoW = uoW;
        _repo = repo;
        _publisher = publisher;
        _logger = logger;
    }

    public async Task<Guid> Handle(CreateProductCommand cmd, CancellationToken ct)
    {
        _logger.LogInformation("Creating product: {Name}", cmd.Name);

        using (_uoW.BeginTransaction())
        {
            var product = new Product
            {
                Id = Guid.NewGuid(),
                Name = cmd.Name,
                Price = cmd.Price,
                Category = cmd.Category,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = "API-User"
            };
            
            await _repo.AddAsync(product, ct);
            
            // Publish event inside transaction (Outbox Pattern)
            await _publisher.CreateMessageAsync("evt-catalog-product-created", product);
            
            _uoW.Commit();
            
            _logger.LogInformation("Product created successfully: {Id}", product.Id);
            return product.Id;
        }
    }
}
```

---

### Step 6: Repository Interface

**File**: `apps/products-api/src/Application.Interfaces/IProductRepository.cs`

**Implementation**:
```csharp
using ProductsApi.Domain.Entities;

namespace ProductsApi.Application.Interfaces;

public interface IProductRepository : IRepository<Product, Guid>
{
    Task<Product?> GetByNameAsync(string name, CancellationToken ct = default);
}
```

---

### Step 7: Repository Implementation

**File**: `apps/products-api/src/Repositories.SQL/ProductRepository.cs`

**Implementation**:
```csharp
using Dapper;
using ProductsApi.Domain.Entities;
using ProductsApi.Application.Interfaces;
using LaNacion.Core.Infraestructure.Data.Relational;

namespace ProductsApi.Repositories.SQL;

public class ProductRepository : BaseRepository<Product, Guid>, IProductRepository
{
    public ProductRepository(IContext context) : base(context, "Products") { }

    public override async Task<Guid> AddAsync(Product entity, CancellationToken ct = default)
    {
        const string sql = @"
            INSERT INTO Products(Id, Name, Price, Category, CreatedAt, CreatedBy)
            VALUES (@Id, @Name, @Price, @Category, @CreatedAt, @CreatedBy)";

        await _context.Connection.ExecuteAsync(sql, entity, Transaction);
        return entity.Id;
    }

    public async Task<Product?> GetByNameAsync(string name, CancellationToken ct = default)
    {
        const string sql = "SELECT * FROM Products WHERE Name = @Name";
        return await _context.Connection.QueryFirstOrDefaultAsync<Product>(sql, new { Name = name });
    }
}
```

---

### Step 8: Endpoint

**File**: `apps/products-api/src/Api/Endpoints/ProductEndpoints.cs`

**Implementation**:
```csharp
using MediatR;
using ProductsApi.Application.Commands;

namespace ProductsApi.Api.Endpoints;

public class ProductEndpoints : IEndpointDefinition
{
    public void DefineEndpoints(WebApplication app)
    {
        app.MapPost("/api/v1/products", async (
            CreateProductCommand cmd,
            IMediator mediator,
            CancellationToken ct) =>
        {
            var id = await mediator.Send(cmd, ct);
            return Results.Created($"/api/v1/products/{id}", new { id });
        })
        .WithName("CreateProduct")
        .WithTags("Products")
        .Produces<Guid>(201)
        .Produces(400)
        .Produces(500);
    }
}
```

---

### Step 9: DI Registration

**File**: `apps/products-api/src/Api/Program.cs`

**Implementation**:
```csharp
// Add to ConfigureServices
services.AddScoped<IProductRepository, ProductRepository>();
services.AddScoped<CreateProductCommandValidator>();
services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(CreateProductHandler).Assembly));
services.AddValidatorsFromAssemblyContaining<CreateProductCommandValidator>();
```

---

### Step 10: Configuration

**File**: `apps/products-api/src/Api/appsettings.json`

**Implementation**:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=ProductsDb;..."
  },
  "EventPublisher": {
    "Enabled": true,
    "TopicArn": "arn:aws:sns:us-east-1:123456789012:product-events"
  }
}
```

---

### Step 11: Unit Tests

**File**: `tests/products-api-tests/CreateProductHandlerTests.cs`

**Implementation**:
```csharp
using Xunit;
using Moq;
using FluentAssertions;
using ProductsApi.Application.Handlers;
using ProductsApi.Application.Commands;

namespace ProductsApi.Tests;

public class CreateProductHandlerTests
{
    private readonly Mock<IProductRepository> _repoMock;
    private readonly Mock<IUnitOfWork> _uowMock;
    private readonly Mock<IMessagePublisher> _publisherMock;
    private readonly Mock<ILogger<CreateProductHandler>> _loggerMock;
    private readonly CreateProductHandler _handler;

    public CreateProductHandlerTests()
    {
        _repoMock = new Mock<IProductRepository>();
        _uowMock = new Mock<IUnitOfWork>();
        _publisherMock = new Mock<IMessagePublisher>();
        _loggerMock = new Mock<ILogger<CreateProductHandler>>();
        
        _handler = new CreateProductHandler(_uowMock.Object, _repoMock.Object, 
            _publisherMock.Object, _loggerMock.Object);
    }

    [Fact]
    public async Task Handle_ValidCommand_CreatesProduct()
    {
        // Arrange
        var cmd = new CreateProductCommand("Laptop", 999.99m, "Electronics");

        // Act
        var result = await _handler.Handle(cmd, CancellationToken.None);

        // Assert
        result.Should().NotBeEmpty();
        _repoMock.Verify(x => x.AddAsync(It.IsAny<Product>(), It.IsAny<CancellationToken>()), Times.Once);
        _uowMock.Verify(x => x.Commit(), Times.Once);
    }

    [Fact]
    public async Task Handle_ValidCommand_PublishesEvent()
    {
        // Arrange
        var cmd = new CreateProductCommand("Laptop", 999.99m, "Electronics");

        // Act
        await _handler.Handle(cmd, CancellationToken.None);

        // Assert
        _publisherMock.Verify(x => x.CreateMessageAsync(
            "evt-catalog-product-created", 
            It.IsAny<Product>()), Times.Once);
    }

    [Fact]
    public async Task Validator_EmptyName_ReturnsError()
    {
        // Arrange
        var validator = new CreateProductCommandValidator();
        var cmd = new CreateProductCommand("", 999.99m, "Electronics");

        // Act
        var result = await validator.ValidateAsync(cmd);

        // Assert
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName == "Name");
    }

    [Fact]
    public async Task Validator_NegativePrice_ReturnsError()
    {
        // Arrange
        var validator = new CreateProductCommandValidator();
        var cmd = new CreateProductCommand("Laptop", -10m, "Electronics");

        // Act
        var result = await validator.ValidateAsync(cmd);

        // Assert
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName == "Price");
    }
}
```

---

### Step 12: Documentation

**Files to Update**:
- `ai-specs/specs/api-spec.yml`
- `ai-specs/specs/data-model.md`

**API Spec Update**:
```yaml
/api/v1/products:
  post:
    summary: Create a new product
    tags:
      - Products
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            required:
              - name
              - price
              - category
            properties:
              name:
                type: string
                maxLength: 200
              price:
                type: number
                format: decimal
                minimum: 0
              category:
                type: string
                enum: [Electronics, Clothing, Food]
    responses:
      201:
        description: Product created successfully
        content:
          application/json:
            schema:
              type: object
              properties:
                id:
                  type: string
                  format: uuid
      400:
        description: Validation error
      500:
        description: Internal server error
```

**Data Model Update**:
```markdown
## Product Entity

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| Id | Guid | Primary key | Required, Unique |
| Name | string | Product name | Required, Max 200 chars |
| Price | decimal | Product price | Required, > 0 |
| Category | string | Product category | Required, Enum |
| CreatedAt | DateTime | Creation timestamp | Auto-generated |
| CreatedBy | string | Creator identifier | Auto-populated |

### Events Published
- `evt-catalog-product-created`: Published when a new product is created
```

---

## Testing Checklist

- [ ] All unit tests pass
- [ ] Code coverage ≥ 80%
- [ ] Validation works correctly
- [ ] Event publishing verified
- [ ] HTTP status codes correct
- [ ] Documentation updated
- [ ] Monorepo structure validated

---

**Plan created by**: lanacion-backend-planner v1.0.0
**Standards reference**: `ai-specs/specs/ln-susc-api-standards.mdc`
**Monorepo**: Yes (npm run generate:template)
```

---

### Fase 2: Implementación con Skill

**Skill**: `implement-backend-plan`

**Input**: `@SCRUM-700_backend.md`

#### 2.1 Read and Parse Plan
```
✅ Plan file exists: ai-specs/changes/SCRUM-700_backend.md
✅ Backend Type detected: API
✅ Standards Reference: ln-susc-api-standards.mdc
✅ Monorepo Integration: Yes
✅ Branch name: feature/SCRUM-700-api
✅ 12 implementation steps found
```

#### 2.2 Auto-Select Agent
```
📚 Standards Reference: ln-susc-api-standards.mdc

🤖 Adopting role: lanacion-api-developer

Agent Capabilities Loaded:
✅ REST API patterns
✅ CQRS with Commands/Queries
✅ FluentValidation
✅ Event publishing (Outbox Pattern)
✅ HTTP endpoints (Minimal API)
✅ Monorepo integration (npm run generate:template)
✅ Routing to lanacion-nx-monorepo-developer when needed

Agent Notes:
⚠️ Detected monorepo context
⚠️ Will use npm run generate:template for scaffolding
⚠️ Can route to scaffold-monorepo-backend-app skill if needed
```

#### 2.3 Verify Prerequisites
```
✅ Git repository initialized
✅ On main branch
✅ Working directory clean
✅ .NET 6 SDK available
✅ Node.js available (for npm commands)
✅ Monorepo structure detected
```

#### 2.4 Execute Step 0 (Monorepo Scaffolding)
```
🏗️ Step 0: Scaffold Monorepo App

Checking if app exists...
❌ App 'products-api' not found in apps/

Executing scaffolding:
$ npm run generate:template

Interactive prompts:
? Type: API
? Name: products-api
? Template: Minimal API

✅ App scaffolded successfully
✅ Created: apps/products-api/
✅ Updated: .sln
✅ Updated: project.json
✅ Created: tests/products-api-tests/
✅ Updated: cdk/

✅ Step 0 complete: Monorepo scaffolding
```

#### 2.5 Create Feature Branch
```bash
git checkout -b feature/SCRUM-700-api
```
```
✅ Branch created: feature/SCRUM-700-api
```

#### 2.6 Implement Steps Sequentially
```
🔨 Implementing Step 2/12: Domain Entity
✅ Created: apps/products-api/src/Domain/Entities/Product.cs
✅ Step 2/12 complete

🔨 Implementing Step 3/12: CQRS Command
✅ Created: apps/products-api/src/Application/Commands/CreateProductCommand.cs
✅ Step 3/12 complete

🔨 Implementing Step 4/12: Validator
✅ Created: apps/products-api/src/Application/Validators/CreateProductCommandValidator.cs
✅ Applied: FluentValidation rules
✅ Step 4/12 complete

🔨 Implementing Step 5/12: Handler
✅ Created: apps/products-api/src/Application/Handlers/CreateProductHandler.cs
✅ Applied: Unit of Work pattern
✅ Applied: Event publishing (Outbox Pattern)
✅ Applied: Logging
✅ Step 5/12 complete

🔨 Implementing Step 6/12: Repository Interface
✅ Created: apps/products-api/src/Application.Interfaces/IProductRepository.cs
✅ Step 6/12 complete

🔨 Implementing Step 7/12: Repository Implementation
✅ Created: apps/products-api/src/Repositories.SQL/ProductRepository.cs
✅ Applied: Dapper with transactions
✅ Step 7/12 complete

🔨 Implementing Step 8/12: Endpoint
✅ Created: apps/products-api/src/Api/Endpoints/ProductEndpoints.cs
✅ Applied: Minimal API conventions
✅ Applied: REST naming (POST /api/v1/products)
✅ Applied: HTTP status codes (201, 400, 500)
✅ Applied: OpenAPI metadata (WithName, WithTags, Produces)
✅ Step 8/12 complete

🔨 Implementing Step 9/12: DI Registration
✅ Updated: apps/products-api/src/Api/Program.cs
✅ Registered: IProductRepository
✅ Registered: CreateProductCommandValidator
✅ Registered: MediatR
✅ Step 9/12 complete

🔨 Implementing Step 10/12: Configuration
✅ Updated: apps/products-api/src/Api/appsettings.json
✅ Added: ConnectionStrings
✅ Added: EventPublisher configuration
✅ Step 10/12 complete

🔨 Implementing Step 11/12: Unit Tests
✅ Created: tests/products-api-tests/CreateProductHandlerTests.cs
✅ Test: Happy path (product creation)
✅ Test: Event publishing
✅ Test: Validation (empty name)
✅ Test: Validation (negative price)
✅ Step 11/12 complete

🔨 Implementing Step 12/12: Documentation
✅ Updated: ai-specs/specs/api-spec.yml
✅ Updated: ai-specs/specs/data-model.md
✅ Step 12/12 complete
```

#### 2.7 Verify Compilation
```bash
dotnet build apps/products-api/
```
```
✅ Build successful
  0 Warning(s)
  0 Error(s)
```

#### 2.8 Run Tests
```bash
dotnet test tests/products-api-tests/
```
```
✅ All tests pass: 4/4
✅ Coverage: 85%

Test Results:
  ✓ Handle_ValidCommand_CreatesProduct
  ✓ Handle_ValidCommand_PublishesEvent
  ✓ Validator_EmptyName_ReturnsError
  ✓ Validator_NegativePrice_ReturnsError
```

#### 2.9 Completion Status
```
## ✅ Implementation Complete: SCRUM-700

**Backend Type**: API
**Agent**: lanacion-api-developer
**Branch**: feature/SCRUM-700-api
**Monorepo**: Yes (scaffolded with npm run generate:template)

### Progress
- Monorepo scaffolding: Complete ✅
- Steps completed: 12/12 ✅
- Build: Success ✅
- Tests: Pass (4/4) ✅
- Coverage: 85% ✅
- Documentation: Updated ✅

### Files Created/Modified
Monorepo Structure:
- apps/products-api/ (new app)
- .sln (updated)
- project.json (updated)
- tests/products-api-tests/ (new)
- cdk/ (updated)

Application Code:
- apps/products-api/src/Domain/Entities/Product.cs
- apps/products-api/src/Application/Commands/CreateProductCommand.cs
- apps/products-api/src/Application/Validators/CreateProductCommandValidator.cs
- apps/products-api/src/Application/Handlers/CreateProductHandler.cs
- apps/products-api/src/Application.Interfaces/IProductRepository.cs
- apps/products-api/src/Repositories.SQL/ProductRepository.cs
- apps/products-api/src/Api/Endpoints/ProductEndpoints.cs
- apps/products-api/src/Api/Program.cs
- apps/products-api/src/Api/appsettings.json

Tests:
- tests/products-api-tests/CreateProductHandlerTests.cs

Documentation:
- ai-specs/specs/api-spec.yml
- ai-specs/specs/data-model.md

### Agent Decision Validation
✅ Correctly identified as API
✅ Used lanacion-api-developer agent
✅ Applied REST API patterns
✅ Implemented HTTP endpoint
✅ Used Outbox Pattern for event publishing
✅ Applied proper HTTP status codes
✅ Followed ln-susc-api-standards.mdc
✅ Integrated with monorepo (npm run generate:template)
✅ Scaffolded app structure correctly
✅ Updated monorepo configuration files

### Monorepo Integration Validation
✅ Used npm run generate:template for scaffolding
✅ App created under apps/ directory
✅ .sln updated with new project
✅ project.json updated
✅ Tests folder created
✅ CDK configuration updated
✅ Agent aware of lanacion-nx-monorepo-developer routing
```

---

**🎉 Simulación 1 completada. Continuando con Simulación 2...**
