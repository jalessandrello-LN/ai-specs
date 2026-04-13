---
name: plan-frontend
description: Plan a frontend feature implementation with detailed steps and examples
---

# Plan Frontend Feature

Generate a detailed implementation plan for a frontend feature (React component).

## Input

Provide:
- Ticket ID (e.g., SCRUM-501)
- Feature description
- Component requirements
- Acceptance criteria
- User interactions

## Steps

### 1. Analyze Requirements

Read the ticket and extract:
- Feature description
- Acceptance criteria
- User interactions
- State management needs
- API integrations
- Accessibility requirements

### 2. Design Component Structure

Determine:
- Component hierarchy
- Props interfaces
- State management approach (Context, Redux, Zustand, etc.)
- Custom hooks needed
- Styling approach (CSS modules, styled-components, etc.)

### 3. Create Plan Structure

Generate a plan file at `ai-specs/changes/[TICKET-ID]_frontend.md` with:

```markdown
# [TICKET-ID]: [Feature Title]

## Overview
[Feature description]

## Component Structure
[Component hierarchy]

## State Management
[Approach and details]

## Implementation Steps

### Step 1: [Component Setup]
[Description and code example]

### Step 2: [Props and Types]
[Description and code example]

### Step 3: [State Management]
[Description and code example]

### Step 4: [Event Handlers]
[Description and code example]

### Step 5: [Accessibility]
[Description and code example]

### Step 6: [Styling]
[Description and code example]

### Step 7: [Unit Tests]
[Description and test examples]

### Step 8: [Documentation]
[Description of what to update]

## Testing Requirements
- Component rendering test
- User interaction test
- State management test
- Error handling test
- Accessibility test
- Coverage: 80%+

## Accessibility Checklist
- [ ] Labels for all inputs
- [ ] ARIA attributes
- [ ] Keyboard navigation
- [ ] Color contrast
- [ ] Screen reader compatible

## Documentation Updates
- Component JSDoc
- Storybook stories (if applicable)
- README.md (if new feature)
```

### 4. Add Implementation Steps

Include:
- **Step 1**: Component setup with TypeScript interface
- **Step 2**: Props interface and types
- **Step 3**: State management (useState, useContext, etc.)
- **Step 4**: Event handlers and callbacks
- **Step 5**: Accessibility attributes (ARIA, labels, etc.)
- **Step 6**: Styling (CSS modules or styled-components)
- **Step 7**: Unit tests (80%+ coverage)
- **Step 8**: Documentation (JSDoc, Storybook, README)

### 5. Add Code Examples

For each step, provide:
- Complete code example
- File path where it should be created
- Dependencies required
- Imports needed

### 6. Add Testing Strategy

Include:
- Component rendering test example
- User interaction test example
- State management test example
- Error handling test example
- Accessibility test example

### 7. Add Accessibility Requirements

Include:
- ARIA attributes needed
- Keyboard navigation requirements
- Color contrast requirements
- Screen reader compatibility

### 8. Output Plan

Display:
- Plan file location
- Number of implementation steps
- Component structure
- State management approach
- Next command: `develop-frontend @[TICKET-ID]_frontend.md`

## Output

Display:
```
## Plan Generated: SCRUM-501

**Feature**: [Feature Name]
**Implementation Steps**: N
**Estimated Effort**: [Low | Medium | High]

**Component Structure**:
- [Component hierarchy]

**State Management**: [Approach]

**Plan Location**: ai-specs/changes/SCRUM-501_frontend.md

**Next Command**:
develop-frontend @SCRUM-501_frontend.md
```
