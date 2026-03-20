---
description: Develop a backend SQS Listener following standards and best practices
---

# Develop Backend SQS Listener

Implement an SQS event listener following Clean Architecture, CQRS, and Event-Driven patterns.

## Prerequisites

- .NET 6 SDK installed
- Git repository initialized
- Working directory clean
- Plan file available (e.g., `ai-specs/changes/SCRUM-500_backend.md`)

## Steps

### 1. Read the Implementation Plan

Read the plan file provided by the user. Extract:
- Feature description
- Event structure
- Implementation steps
- Testing requirements
- Documentation updates needed

**Validation**: Verify plan exists and is complete. **STOP** if invalid.

### 2. Create Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b feature/[ticket-id]-listener
```

### 3. Implement Each Step

For each step in the plan:

**Before**:
- Announce: "Implementing Step X/N: [Step Title]"
- Read requirements carefully

**During**:
- Create/modify files as specified in plan
- Follow code examples exactly
- Apply standards from `.github/specs/base-standards.mdc`
- Use correct naming conventions

**After**:
- Verify file created/modified
- Announce: "✓ Step X/N complete"

**Pause if**:
- Requirements unclear
- File path doesn't exist
- Code example incomplete
- Missing dependency

### 4. Verify Compilation

```bash
dotnet build
```

**If fails**: **STOP**, report errors, wait for guidance

### 5. Run Tests

```bash
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=lcov
```

**Verify**:
- All tests pass
- Code coverage ≥ 80%

**If fails**: **STOP**, report failures, wait for guidance

### 6. Update Documentation

Update:
- `ai-specs/specs/data-model.md` (if data model changed)

### 7. Commit and Push

```bash
git add .
git commit -m "[TICKET-ID]: Implement [feature description]"
git push origin feature/[ticket-id]-listener
```

## Implementation Patterns

### Domain Event

```csharp
using LaNacion.Core.Infraestructure.Domain.Entities;
using MediatR;

public class SuscripcionCreada : IRequest<ProcessResult>
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
```

### Event Processor (Handler)

```csharp
public class SuscripcionCreadaProcessor : IRequestHandler<SuscripcionCreada, ProcessResult>
{
    private readonly ILogger<SuscripcionCreadaProcessor> _logger;
    private readonly IUnitOfWork _uoW;
    private readonly ISuscripcionRepository _repository;

    public async Task<ProcessResult> Handle(SuscripcionCreada @event, CancellationToken ct)
    {
        try
        {
            _logger.LogInformation(">>> Processing SuscripcionCreada: Id={Id}", @event.Id);

            // Validation
            if (@event.Id == Guid.Empty)
                return new ProcessResult { Succed = false, ErrorDescription = "ID required" };

            // Idempotency check
            var existing = await _repository.GetByIdAsync(@event.Id);
            if (existing != null)
            {
                _logger.LogInformation("Entity already exists, skipping");
                return new ProcessResult { Succed = true, ErrorDescription = "" };
            }

            // Process with transaction
            using (_uoW.BeginTransaction())
            {
                var entity = new Suscripcion
                {
                    Id = @event.Id,
                    Name = @event.Name,
                    LastModifiedBy = "SQS-Worker",
                    LastModifyDate = DateTime.UtcNow
                };

                await _repository.AddAsync(entity);
                _uoW.Commit();
            }

            _logger.LogInformation("<<< SuscripcionCreada processed successfully");
            return new ProcessResult { Succed = true, ErrorDescription = "" };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing SuscripcionCreada");
            return new ProcessResult { Succed = false, ErrorDescription = ex.Message };
        }
    }
}
```

### Repository Interface

```csharp
public interface ISuscripcionRepository : IRepository<Suscripcion, Guid> { }
```

### Repository Implementation

```csharp
public class SuscripcionRepository : BaseRepository<Suscripcion, Guid>, ISuscripcionRepository
{
    public SuscripcionRepository(IContext context) : base(context, "Suscripciones") { }

    public override async Task<Guid> AddAsync(Suscripcion entity, CancellationToken ct = default)
    {
        const string sql = @"
            INSERT INTO Suscripciones(Id, Name, LastModifiedBy, LastModifyDate)
            VALUES (@Id, @Name, @LastModifiedBy, @LastModifyDate)";

        await _context.Connection.ExecuteAsync(sql, entity, Transaction);
        return entity.Id;
    }
}
```

### SQS Configuration

**DI Registration** (ConfigureServicesExtensions.cs):
```csharp
services.AddSingleton(new SqsQueueNameService<SuscripcionCreada>("suscripciones-stg-sqs-ventas-alta"));
services.AddHostedService<SqsQueueConsumerService<SuscripcionCreada>>();
services.AddScoped<ISuscripcionRepository, SuscripcionRepository>();
```

**Configuration** (appsettings.json):
```json
{
  "SQS": {
    "Queues": {
      "suscripciones-stg-sqs-ventas-alta": "https://sqs.us-east-1.amazonaws.com/123456789012/suscripciones-stg-sqs-ventas-alta"
    }
  }
}
```

## Key Patterns

### Idempotency

Always check if entity exists before processing:
```csharp
var existing = await _repository.GetByIdAsync(@event.Id);
if (existing != null)
    return new ProcessResult { Succed = true, ErrorDescription = "" };
```

### Transaction Management

Use Unit of Work for atomic operations:
```csharp
using (_uoW.BeginTransaction())
{
    await _repository.AddAsync(entity);
    _uoW.Commit();
}
```

### Error Handling

Return ProcessResult for SQS message handling:
```csharp
return new ProcessResult 
{ 
    Succed = false, 
    ErrorDescription = "Validation failed" 
};
```

## Testing Requirements

**Minimum 80% coverage required.**

### Happy Path Test

```csharp
[Fact]
public async Task Handle_NewEvent_ProcessesSuccessfully()
{
    _repositoryMock.Setup(x => x.GetByIdAsync(It.IsAny<Guid>())).ReturnsAsync((Suscripcion)null);
    var result = await _processor.Handle(@event, CancellationToken.None);
    result.Succed.Should().BeTrue();
    _repositoryMock.Verify(x => x.AddAsync(It.IsAny<Suscripcion>(), It.IsAny<CancellationToken>()), Times.Once);
}
```

### Idempotency Test

```csharp
[Fact]
public async Task Handle_DuplicateMessage_SkipsProcessing()
{
    _repositoryMock.Setup(x => x.GetByIdAsync(It.IsAny<Guid>())).ReturnsAsync(new Suscripcion { Id = @event.Id });
    var result = await _processor.Handle(@event, CancellationToken.None);
    result.Succed.Should().BeTrue();
    _repositoryMock.Verify(x => x.AddAsync(It.IsAny<Suscripcion>(), It.IsAny<CancellationToken>()), Times.Never);
}
```

### Validation Test

```csharp
[Fact]
public async Task Handle_EmptyId_ReturnsFailure()
{
    var result = await _processor.Handle(new SuscripcionCreada { Id = Guid.Empty }, CancellationToken.None);
    result.Succed.Should().BeFalse();
    result.ErrorDescription.Should().NotBeEmpty();
}
```

## Naming Conventions

- **Event Name**: `evt-{squad}-{entity}-{verb-past}` (e.g., `evt-susc-suscripcion-creada`)
- **Queue Name**: `{product}-{env}-sqs-{event}` (e.g., `suscripciones-stg-sqs-ventas-alta`)
- **Entity Name**: PascalCase (e.g., `Suscripcion`)
- **Squad Code**: 2-4 letter lowercase (e.g., `susc`)

## Quality Checklist

- [ ] Clean Architecture boundaries respected
- [ ] Event implements IRequest<ProcessResult>
- [ ] Processor implements IRequestHandler<Event, ProcessResult>
- [ ] Idempotency check implemented
- [ ] Unit of Work used for transactions
- [ ] 80%+ test coverage achieved
- [ ] SQS queue configured correctly
- [ ] Event naming conventions followed
- [ ] Documentation updated
- [ ] Template boilerplate removed

## Standards Reference

For detailed standards, see `.github/specs/base-standards.mdc`
