---
name: develop-backend-api
description: Develop a backend REST API following standards and best practices
---

# Develop Backend API

Implement a REST API feature following Clean Architecture, CQRS, and Event-Driven patterns.

## Prerequisites

- .NET 6 SDK installed
- Git repository initialized
- Working directory clean
- Plan file available (e.g., `ai-specs/changes/SCRUM-500_backend.md`)

## Steps

### 1. Read the Implementation Plan

Read the plan file provided by the user. Extract:
- Feature description
- Implementation steps
- Testing requirements
- Documentation updates needed

**Validation**: Verify plan exists and is complete. **STOP** if invalid.

### 2. Create Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b feature/[ticket-id]-[description]
```

### 3. Implement Each Step

For each step in the plan:

**Before**:
- Announce: "Implementing Step X/N: [Step Title]"
- Read requirements carefully

**During**:
- Create/modify files as specified in plan
- Follow code examples exactly
- Apply standards from `ai-specs/specs/base-standards.mdc`
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
- `ai-specs/specs/api-spec.yml` (if endpoints changed)
- `ai-specs/specs/data-model.md` (if data model changed)

### 7. Commit and Push

```bash
git add .
git commit -m "[TICKET-ID]: Implement [feature description]"
git push origin feature/[ticket-id]-[description]
```

## Implementation Patterns

### CQRS Command

```csharp
public record CreateCustomerCommand(string Name) : IRequest<Guid>;
```

### Validator

```csharp
public class CreateCustomerCommandValidator : AbstractValidator<CreateCustomerCommand>
{
    public CreateCustomerCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
    }
}
```

### Handler

```csharp
public class CreateCustomerHandler : IRequestHandler<CreateCustomerCommand, Guid>
{
    private readonly IUnitOfWork _uoW;
    private readonly ICustomerRepository _repo;
    private readonly IMessagePublisher _publisher;

    public async Task<Guid> Handle(CreateCustomerCommand cmd, CancellationToken ct)
    {
        using (_uoW.BeginTransaction())
        {
            var customer = new Customer { Name = cmd.Name };
            await _repo.AddAsync(customer);
            await _publisher.CreateMessageAsync("evt-squad-customer-created", customer);
            _uoW.Commit();
            return customer.Id;
        }
    }
}
```

### Endpoint

```csharp
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
```

## Testing Requirements

**Minimum 80% coverage required.**

### Happy Path Test

```csharp
[Fact]
public async Task Handle_ValidCommand_ReturnsSuccess()
{
    var command = new CreateCustomerCommand { Name = "Test" };
    var result = await _handler.Handle(command, CancellationToken.None);
    result.Should().NotBeEmpty();
    _repositoryMock.Verify(x => x.AddAsync(It.IsAny<Customer>(), It.IsAny<CancellationToken>()), Times.Once);
}
```

### Validation Test

```csharp
[Fact]
public async Task Handle_EmptyName_ReturnsValidationError()
{
    var validator = new CreateCustomerCommandValidator();
    var result = await validator.ValidateAsync(new CreateCustomerCommand { Name = "" });
    result.IsValid.Should().BeFalse();
}
```

### Event Publishing Test

```csharp
[Fact]
public async Task Handle_ValidCommand_PublishesEvent()
{
    await _handler.Handle(command, CancellationToken.None);
    _publisherMock.Verify(x => x.CreateMessageAsync(It.IsAny<string>(), It.IsAny<object>()), Times.Once);
}
```

## Naming Conventions

- **Commands**: `cmd-{verb}-{entity}` (e.g., `cmd-create-customer`)
- **Events**: `evt-{squad}-{entity}-{verb-past}` (e.g., `evt-susc-cliente-creado`)
- **REST URLs**: Plural nouns, no verbs (e.g., `POST /api/v1/customers`)

## Quality Checklist

- [ ] Clean Architecture boundaries respected
- [ ] CQRS pattern correctly applied
- [ ] Unit of Work used for transactions
- [ ] Events published inside transactions (Outbox Pattern)
- [ ] FluentValidation implemented
- [ ] 80%+ test coverage achieved
- [ ] No hardcoded credentials
- [ ] REST naming conventions followed
- [ ] Documentation updated
- [ ] Template boilerplate removed

## Standards Reference

For detailed standards, see `ai-specs/specs/base-standards.mdc`
