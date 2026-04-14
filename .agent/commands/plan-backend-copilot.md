---
name: plan-backend
description: Plan a backend feature implementation with detailed steps and examples
---

# Plan Backend Feature

Generate a detailed implementation plan for a backend feature (API or Listener).

## Input

Provide:
- Ticket ID (e.g., HU-500)
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

## Output

Display:
```
## Plan Generated: HU-500

**Backend Type**: [API | Listener]
**Implementation Steps**: N
**Estimated Effort**: [Low | Medium | High]

**Plan Location**: ai-specs/changes/HU-500_backend.md

**Next Command**:
develop-backend-api @HU-500_backend.md
# or
develop-backend-listener @HU-500_backend.md
```
