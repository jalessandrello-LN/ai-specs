---
description: Develop a frontend React component following standards and best practices
---

# Develop Frontend Component

Implement a React component with TypeScript, state management, testing, and accessibility.

## Prerequisites

- Node.js installed
- npm/yarn available
- Git repository initialized
- Working directory clean
- Plan file available (e.g., `ai-specs/changes/SCRUM-501_frontend.md`)

## Steps

### 1. Read the Implementation Plan

Read the plan file provided by the user. Extract:
- Feature description
- Component structure
- State management requirements
- Testing requirements
- Accessibility requirements
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
- Apply standards from `.github/specs/base-standards.mdc`
- Use TypeScript types correctly
- Add accessibility attributes (ARIA)
- Implement responsive design

**After**:
- Verify file created/modified
- Announce: "✓ Step X/N complete"

**Pause if**:
- Requirements unclear
- File path doesn't exist
- Code example incomplete
- Missing dependency

### 4. Install Dependencies

If new packages added:

```bash
npm install
# or yarn install
```

### 5. Verify Compilation

```bash
npm run build
# or yarn build
```

**If fails**: **STOP**, report errors, wait for guidance

### 6. Run Tests

```bash
npm test
# or yarn test
```

**Verify**:
- All tests pass
- Code coverage ≥ 80%

**If fails**: **STOP**, report failures, wait for guidance

### 7. Validate Accessibility

Check:
- [ ] Interactive elements have labels
- [ ] Proper ARIA attributes used
- [ ] Keyboard navigation works
- [ ] Color contrast meets WCAG
- [ ] Screen reader compatible

### 8. Run Linter

```bash
npm run lint
# or yarn lint
```

Apply auto-fixes if available:
```bash
npm run lint:fix
```

### 9. Update Documentation

Update:
- Component documentation (JSDoc/TSDoc)
- Storybook stories (if applicable)
- README.md (if new feature)
- API integration docs (if backend calls added)

### 10. Commit and Push

```bash
git add .
git commit -m "[TICKET-ID]: Implement [feature description]"
git push origin feature/[ticket-id]-[description]
```

## Component Structure

### TypeScript Component

```typescript
import React, { useState, useCallback } from 'react';
import styles from './SubscriptionForm.module.css';

interface SubscriptionFormProps {
  onSubmit: (data: SubscriptionData) => Promise<void>;
  isLoading?: boolean;
}

interface SubscriptionData {
  name: string;
  email: string;
}

export const SubscriptionForm: React.FC<SubscriptionFormProps> = ({
  onSubmit,
  isLoading = false,
}) => {
  const [formData, setFormData] = useState<SubscriptionData>({ name: '', email: '' });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  }, []);

  const handleSubmit = useCallback(async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await onSubmit(formData);
    } catch (error) {
      setErrors({ submit: 'Failed to submit form' });
    }
  }, [formData, onSubmit]);

  return (
    <form onSubmit={handleSubmit} className={styles.form} aria-label="Subscription form">
      <div className={styles.field}>
        <label htmlFor="name">Name</label>
        <input
          id="name"
          name="name"
          type="text"
          value={formData.name}
          onChange={handleChange}
          disabled={isLoading}
          aria-required="true"
          aria-invalid={!!errors.name}
        />
        {errors.name && <span className={styles.error}>{errors.name}</span>}
      </div>

      <div className={styles.field}>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          name="email"
          type="email"
          value={formData.email}
          onChange={handleChange}
          disabled={isLoading}
          aria-required="true"
          aria-invalid={!!errors.email}
        />
        {errors.email && <span className={styles.error}>{errors.email}</span>}
      </div>

      <button type="submit" disabled={isLoading} aria-busy={isLoading}>
        {isLoading ? 'Submitting...' : 'Subscribe'}
      </button>

      {errors.submit && <div className={styles.error} role="alert">{errors.submit}</div>}
    </form>
  );
};
```

### Component Test

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { SubscriptionForm } from './SubscriptionForm';

describe('SubscriptionForm', () => {
  it('renders form with inputs', () => {
    render(<SubscriptionForm onSubmit={jest.fn()} />);
    expect(screen.getByLabelText('Name')).toBeInTheDocument();
    expect(screen.getByLabelText('Email')).toBeInTheDocument();
  });

  it('submits form with data', async () => {
    const onSubmit = jest.fn().mockResolvedValue(undefined);
    render(<SubscriptionForm onSubmit={onSubmit} />);

    fireEvent.change(screen.getByLabelText('Name'), { target: { value: 'John' } });
    fireEvent.change(screen.getByLabelText('Email'), { target: { value: 'john@example.com' } });
    fireEvent.click(screen.getByRole('button', { name: /subscribe/i }));

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({ name: 'John', email: 'john@example.com' });
    });
  });

  it('shows loading state', () => {
    render(<SubscriptionForm onSubmit={jest.fn()} isLoading={true} />);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

## Accessibility Checklist

- [ ] All form inputs have associated labels
- [ ] ARIA attributes used correctly (aria-label, aria-required, aria-invalid, aria-busy)
- [ ] Keyboard navigation works (Tab, Enter, Escape)
- [ ] Color contrast meets WCAG AA standards
- [ ] Error messages associated with inputs
- [ ] Loading states announced (aria-busy)
- [ ] Focus management implemented
- [ ] Screen reader compatible

## Testing Requirements

**Minimum 80% coverage required.**

### Test Categories

**Component Rendering**:
```typescript
it('renders all required elements', () => {
  render(<SubscriptionForm onSubmit={jest.fn()} />);
  expect(screen.getByLabelText('Name')).toBeInTheDocument();
});
```

**User Interactions**:
```typescript
it('handles form submission', async () => {
  const onSubmit = jest.fn().mockResolvedValue(undefined);
  render(<SubscriptionForm onSubmit={onSubmit} />);
  fireEvent.click(screen.getByRole('button'));
  await waitFor(() => expect(onSubmit).toHaveBeenCalled());
});
```

**State Management**:
```typescript
it('updates form state on input change', () => {
  render(<SubscriptionForm onSubmit={jest.fn()} />);
  fireEvent.change(screen.getByLabelText('Name'), { target: { value: 'Test' } });
  expect(screen.getByLabelText('Name')).toHaveValue('Test');
});
```

**Error Handling**:
```typescript
it('displays error on submission failure', async () => {
  const onSubmit = jest.fn().mockRejectedValue(new Error('Failed'));
  render(<SubscriptionForm onSubmit={onSubmit} />);
  fireEvent.click(screen.getByRole('button'));
  await waitFor(() => {
    expect(screen.getByText(/failed to submit/i)).toBeInTheDocument();
  });
});
```

## Naming Conventions

- **Components**: PascalCase (e.g., `SubscriptionForm`)
- **Hooks**: camelCase with `use` prefix (e.g., `useFormValidation`)
- **Props interfaces**: `[ComponentName]Props` (e.g., `SubscriptionFormProps`)
- **CSS modules**: kebab-case (e.g., `subscription-form.module.css`)
- **Test files**: `[Component].test.tsx`

## Quality Checklist

- [ ] TypeScript types properly defined
- [ ] Props interface created
- [ ] State management implemented
- [ ] Event handlers defined
- [ ] Accessibility attributes added
- [ ] Error boundaries implemented
- [ ] Loading states handled
- [ ] Responsive design applied
- [ ] 80%+ test coverage achieved
- [ ] Linting passed
- [ ] Documentation updated

## Standards Reference

For detailed standards, see `.github/specs/base-standards.mdc`
