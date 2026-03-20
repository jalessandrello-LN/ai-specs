---
description: Plan a backend feature implementation with detailed steps and examples
---

# Plan Backend Feature

Generate a detailed implementation plan for a backend feature (API or Listener).

## Input

Provide:
- Ticket ID (e.g., SCRUM-500)
- Feature description
- Backend type: API or Listener
- Acceptance criteria

## Steps

### 1. Analyze Requirements

Read the ticket and extract:
- Feature description
- Acceptance criteria
- Business rules
- Data model changes
- API endpoints (if API)
- Events (if Listener)

### 2. Determine Backend Type

Ask if not clear:
- **API**: REST endpoint with CQRS command/query
- **Listener**: SQS event processor

### 3. Create Plan Structure

Generate a plan file at `ai-specs/changes/[TICKET-ID]_backend.md` with:

```markdown
# [TICKET-ID]: [Feature Title]

## Overview
[Feature description]

## Backend Type
[API | Listener]

## Standards Reference
[ln-susc-api-standards.mdc | ln-susc-listener-standards.mdc]

## Implementation Steps

### Step 1: [Domain Layer]
[Description and code example]

### Step 2: [Application Layer]
[Description and code example]

### Step 3: [Infrastructure Layer]
[Description and code example]

### Step 4: [Configuration]
[Description and code example]

### Step 5: [Unit Tests]
[Description and test examples]

### Step 6: [Documentation]
[Description of what to update]

## Testing Requirements
- Happy path test
- Validation test
- Error handling test
- Coverage: 80%+

## Documentation Updates
- api-spec.yml (if API)
- data-model.md
```

### 4. For API Plans

Include:
- **Step 1**: Domain entity/value object
- **Step 2**: CQRS command/query and validator
- **Step 3**: MediatR handler
- **Step 4**: Repository interface and implementation
- **Step 5**: Endpoint definition
- **Step 6**: DI registration
- **Step 7**: Configuration (appsettings.json)
- **Step 8**: Unit tests (80%+ coverage)
- **Step 9**: API documentation (api-spec.yml)
- **Step 10**: Data model documentation (data-model.md)

### 5. For Listener Plans

Include:
- **Step 1**: Domain event (IRequest<ProcessResult>)
- **Step 2**: Event processor (IRequestHandler)
- **Step 3**: Repository interface and implementation
- **Step 4**: SQS configuration
- **Step 5**: DI registration
- **Step 6**: Configuration (appsettings.json)
- **Step 7**: Unit tests (80%+ coverage, including idempotency)
- **Step 8**: Data model documentation (data-model.md)

### 6. Add Code Examples

For each step, provide:
- Complete code example
- File path where it should be created
- Dependencies required
- Configuration needed

### 7. Add Testing Strategy

Include:
- Happy path test example
- Validation test example
- Error handling test example
- Idempotency test (for Listeners)
- Event publishing test (for APIs)

### 8. Output Plan

Display:
- Plan file location
- Number of implementation steps
- Estimated effort
- Next command: `develop-backend-api @[TICKET-ID]_backend.md` or `develop-backend-listener @[TICKET-ID]_backend.md`

## Plan Template for API

```markdown
# SCRUM-500: Create Customer API

## Overview
Create a REST API endpoint to create new customers with validation and event publishing.

## Backend Type
API

## Standards Reference
ln-susc-api-standards.mdc

## Implementation Steps

### Step 1: Domain Entity
Create the Customer entity in `Domain/Entities/Customer.cs`:

\`\`\`csharp
public class Customer
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }
    public DateTime CreatedAt { get; set; }
}
\`\`\`

### Step 2: CQRS Command and Validator
Create command in `Application/Commands/CreateCustomerCommand.cs`:

\`\`\`csharp
public record CreateCustomerCommand(string Name, string Email) : IRequest<Guid>;

public class CreateCustomerCommandValidator : AbstractValidator<CreateCustomerCommand>
{
    public CreateCustomerCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Email).NotEmpty().EmailAddress();
    }
}
\`\`\`

### Step 3: MediatR Handler
Create handler in `Application/Handlers/CreateCustomerHandler.cs`:

\`\`\`csharp
public class CreateCustomerHandler : IRequestHandler<CreateCustomerCommand, Guid>
{
    private readonly IUnitOfWork _uoW;
    private readonly ICustomerRepository _repo;
    private readonly IMessagePublisher _publisher;

    public async Task<Guid> Handle(CreateCustomerCommand cmd, CancellationToken ct)
    {
        using (_uoW.BeginTransaction())
        {
            var customer = new Customer 
            { 
                Id = Guid.NewGuid(),
                Name = cmd.Name,
                Email = cmd.Email,
                CreatedAt = DateTime.UtcNow
            };
            
            await _repo.AddAsync(customer);
            await _publisher.CreateMessageAsync("evt-susc-customer-created", customer);
            _uoW.Commit();
            return customer.Id;
        }
    }
}
\`\`\`

### Step 4: Repository
Create repository in `Repositories.SQL/CustomerRepository.cs`:

\`\`\`csharp
public interface ICustomerRepository : IRepository<Customer, Guid> { }

public class CustomerRepository : BaseRepository<Customer, Guid>, ICustomerRepository
{
    public CustomerRepository(IContext context) : base(context, "Customers") { }

    public override async Task<Guid> AddAsync(Customer entity, CancellationToken ct = default)
    {
        const string sql = "INSERT INTO Customers(Id, Name, Email, CreatedAt) VALUES (@Id, @Name, @Email, @CreatedAt)";
        await _context.Connection.ExecuteAsync(sql, entity, Transaction);
        return entity.Id;
    }
}
\`\`\`

### Step 5: Endpoint
Create endpoint in `Endpoints/CustomerEndpoints.cs`:

\`\`\`csharp
public class CustomerEndpoints : IEndpointDefinition
{
    public void DefineEndpoints(WebApplication app)
    {
        app.MapPost("/api/v1/customers", async (CreateCustomerCommand cmd, IMediator mediator) =>
        {
            var id = await mediator.Send(cmd);
            return Results.Created($"/api/v1/customers/{id}", new { id });
        });
    }
}
\`\`\`

### Step 6: DI Registration
Update `ConfigureServicesExtensions.cs`:

\`\`\`csharp
services.AddScoped<ICustomerRepository, CustomerRepository>();
services.AddScoped<CreateCustomerCommandValidator>();
\`\`\`

### Step 7: Configuration
Add to `appsettings.json`:

\`\`\`json
{
  "Database": {
    "ConnectionString": "Server=localhost;Database=MyDb;..."
  }
}
\`\`\`

### Step 8: Unit Tests
Create tests in `Tests/CreateCustomerHandlerTests.cs`:

\`\`\`csharp
[Fact]
public async Task Handle_ValidCommand_CreatesCustomer()
{
    var cmd = new CreateCustomerCommand("John", "john@example.com");
    var result = await _handler.Handle(cmd, CancellationToken.None);
    result.Should().NotBeEmpty();
    _repoMock.Verify(x => x.AddAsync(It.IsAny<Customer>(), It.IsAny<CancellationToken>()), Times.Once);
}

[Fact]
public async Task Handle_InvalidEmail_ReturnsValidationError()
{
    var validator = new CreateCustomerCommandValidator();
    var result = await validator.ValidateAsync(new CreateCustomerCommand("John", "invalid"));
    result.IsValid.Should().BeFalse();
}
\`\`\`

### Step 9: API Documentation
Update `ai-specs/specs/api-spec.yml`:

\`\`\`yaml
/api/v1/customers:
  post:
    summary: Create a new customer
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              name:
                type: string
              email:
                type: string
    responses:
      201:
        description: Customer created
\`\`\`

### Step 10: Data Model Documentation
Update `ai-specs/specs/data-model.md`:

\`\`\`markdown
## Customer Entity

| Field | Type | Description |
|-------|------|-------------|
| Id | Guid | Primary key |
| Name | string | Customer name (max 100) |
| Email | string | Customer email |
| CreatedAt | DateTime | Creation timestamp |
\`\`\`

## Testing Requirements
- Happy path: Valid command creates customer
- Validation: Invalid email rejected
- Event publishing: Event published on creation
- Coverage: 80%+

## Next Steps
Run: `develop-backend-api @SCRUM-500_backend.md`
```

## Plan Template for Listener

```markdown
# SCRUM-500: Process Subscription Events

## Overview
Create an SQS listener to process subscription creation events with idempotency.

## Backend Type
Listener

## Standards Reference
ln-susc-listener-standards.mdc

## Implementation Steps

### Step 1: Domain Event
Create event in `Domain.Events/v1/SuscripcionCreada.cs`:

\`\`\`csharp
public class SuscripcionCreada : IRequest<ProcessResult>
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
\`\`\`

### Step 2: Event Processor
Create processor in `Application/SuscripcionCreadaProcessor.cs`:

\`\`\`csharp
public class SuscripcionCreadaProcessor : IRequestHandler<SuscripcionCreada, ProcessResult>
{
    private readonly ILogger<SuscripcionCreadaProcessor> _logger;
    private readonly IUnitOfWork _uoW;
    private readonly ISuscripcionRepository _repo;

    public async Task<ProcessResult> Handle(SuscripcionCreada @event, CancellationToken ct)
    {
        try
        {
            if (@event.Id == Guid.Empty)
                return new ProcessResult { Succed = false, ErrorDescription = "ID required" };

            var existing = await _repo.GetByIdAsync(@event.Id);
            if (existing != null)
                return new ProcessResult { Succed = true, ErrorDescription = "" };

            using (_uoW.BeginTransaction())
            {
                var entity = new Suscripcion { Id = @event.Id, Name = @event.Name };
                await _repo.AddAsync(entity);
                _uoW.Commit();
            }

            return new ProcessResult { Succed = true, ErrorDescription = "" };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing event");
            return new ProcessResult { Succed = false, ErrorDescription = ex.Message };
        }
    }
}
\`\`\`

### Step 3: Repository
Create repository in `Repositories.SQL/SuscripcionRepository.cs`:

\`\`\`csharp
public interface ISuscripcionRepository : IRepository<Suscripcion, Guid> { }

public class SuscripcionRepository : BaseRepository<Suscripcion, Guid>, ISuscripcionRepository
{
    public SuscripcionRepository(IContext context) : base(context, "Suscripciones") { }

    public override async Task<Guid> AddAsync(Suscripcion entity, CancellationToken ct = default)
    {
        const string sql = "INSERT INTO Suscripciones(Id, Name) VALUES (@Id, @Name)";
        await _context.Connection.ExecuteAsync(sql, entity, Transaction);
        return entity.Id;
    }
}
\`\`\`

### Step 4: SQS Configuration
Update `ConfigureServicesExtensions.cs`:

\`\`\`csharp
services.AddSingleton(new SqsQueueNameService<SuscripcionCreada>("suscripciones-stg-sqs-ventas-alta"));
services.AddHostedService<SqsQueueConsumerService<SuscripcionCreada>>();
services.AddScoped<ISuscripcionRepository, SuscripcionRepository>();
\`\`\`

### Step 5: Configuration
Add to `appsettings.json`:

\`\`\`json
{
  "SQS": {
    "Queues": {
      "suscripciones-stg-sqs-ventas-alta": "https://sqs.us-east-1.amazonaws.com/123456789012/suscripciones-stg-sqs-ventas-alta"
    }
  }
}
\`\`\`

### Step 6: Unit Tests
Create tests in `Tests/SuscripcionCreadaProcessorTests.cs`:

\`\`\`csharp
[Fact]
public async Task Handle_NewEvent_ProcessesSuccessfully()
{
    _repoMock.Setup(x => x.GetByIdAsync(It.IsAny<Guid>())).ReturnsAsync((Suscripcion)null);
    var result = await _processor.Handle(@event, CancellationToken.None);
    result.Succed.Should().BeTrue();
}

[Fact]
public async Task Handle_DuplicateEvent_SkipsProcessing()
{
    _repoMock.Setup(x => x.GetByIdAsync(It.IsAny<Guid>())).ReturnsAsync(new Suscripcion { Id = @event.Id });
    var result = await _processor.Handle(@event, CancellationToken.None);
    result.Succed.Should().BeTrue();
    _repoMock.Verify(x => x.AddAsync(It.IsAny<Suscripcion>(), It.IsAny<CancellationToken>()), Times.Never);
}
\`\`\`

### Step 7: Data Model Documentation
Update `ai-specs/specs/data-model.md`:

\`\`\`markdown
## Suscripcion Entity

| Field | Type | Description |
|-------|------|-------------|
| Id | Guid | Primary key |
| Name | string | Subscription name |
\`\`\`

## Testing Requirements
- Happy path: New event processed
- Idempotency: Duplicate event skipped
- Validation: Invalid event rejected
- Coverage: 80%+

## Next Steps
Run: `develop-backend-listener @SCRUM-500_backend.md`
```

## Output

Display:
```
## Plan Generated: SCRUM-500

**Backend Type**: [API | Listener]
**Implementation Steps**: N
**Estimated Effort**: [Low | Medium | High]

**Plan Location**: ai-specs/changes/SCRUM-500_backend.md

**Next Command**:
develop-backend-api @SCRUM-500_backend.md
# or
develop-backend-listener @SCRUM-500_backend.md
```
