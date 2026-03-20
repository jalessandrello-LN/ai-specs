---
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

## Plan Template

```markdown
# SCRUM-501: Subscription Form Component

## Overview
Create a subscription form component with validation, error handling, and accessibility.

## Component Structure
```
SubscriptionForm (main component)
├── FormInput (reusable input component)
├── ValidationMessage (error display)
└── SubmitButton (submit button with loading state)
```

## State Management
- Local state with useState for form data and errors
- useCallback for event handlers
- Optional: useContext for form context if needed

## Implementation Steps

### Step 1: Component Setup
Create `src/components/SubscriptionForm/SubscriptionForm.tsx`:

\`\`\`typescript
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

  return (
    <form className={styles.form} aria-label="Subscription form">
      {/* Form content */}
    </form>
  );
};
\`\`\`

### Step 2: Props and Types
Define types in `src/types/subscription.ts`:

\`\`\`typescript
export interface SubscriptionData {
  name: string;
  email: string;
}

export interface SubscriptionFormProps {
  onSubmit: (data: SubscriptionData) => Promise<void>;
  isLoading?: boolean;
  onSuccess?: () => void;
  onError?: (error: Error) => void;
}

export interface FormErrors {
  name?: string;
  email?: string;
  submit?: string;
}
\`\`\`

### Step 3: State Management
Update `SubscriptionForm.tsx`:

\`\`\`typescript
const [formData, setFormData] = useState<SubscriptionData>({ name: '', email: '' });
const [errors, setErrors] = useState<FormErrors>({});
const [touched, setTouched] = useState<Record<string, boolean>>({});

const handleChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
  const { name, value } = e.target;
  setFormData(prev => ({ ...prev, [name]: value }));
  if (errors[name]) {
    setErrors(prev => ({ ...prev, [name]: '' }));
  }
}, [errors]);

const handleBlur = useCallback((e: React.FocusEvent<HTMLInputElement>) => {
  const { name } = e.target;
  setTouched(prev => ({ ...prev, [name]: true }));
}, []);
\`\`\`

### Step 4: Event Handlers
Add validation and submission:

\`\`\`typescript
const validateForm = (): boolean => {
  const newErrors: FormErrors = {};
  
  if (!formData.name.trim()) {
    newErrors.name = 'Name is required';
  }
  
  if (!formData.email.trim()) {
    newErrors.email = 'Email is required';
  } else if (!/^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/.test(formData.email)) {
    newErrors.email = 'Invalid email format';
  }
  
  setErrors(newErrors);
  return Object.keys(newErrors).length === 0;
};

const handleSubmit = useCallback(async (e: React.FormEvent) => {
  e.preventDefault();
  
  if (!validateForm()) return;
  
  try {
    await onSubmit(formData);
    setFormData({ name: '', email: '' });
    setTouched({});
  } catch (error) {
    setErrors(prev => ({
      ...prev,
      submit: error instanceof Error ? error.message : 'Failed to submit form'
    }));
  }
}, [formData, onSubmit]);
\`\`\`

### Step 5: Accessibility
Add ARIA attributes:

\`\`\`typescript
<form onSubmit={handleSubmit} className={styles.form} aria-label="Subscription form">
  <div className={styles.field}>
    <label htmlFor="name">Name</label>
    <input
      id="name"
      name="name"
      type="text"
      value={formData.name}
      onChange={handleChange}
      onBlur={handleBlur}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={!!errors.name}
      aria-describedby={errors.name ? 'name-error' : undefined}
    />
    {errors.name && (
      <span id="name-error" className={styles.error} role="alert">
        {errors.name}
      </span>
    )}
  </div>

  <button type="submit" disabled={isLoading} aria-busy={isLoading}>
    {isLoading ? 'Submitting...' : 'Subscribe'}
  </button>

  {errors.submit && (
    <div className={styles.error} role="alert">
      {errors.submit}
    </div>
  )}
</form>
\`\`\`

### Step 6: Styling
Create `src/components/SubscriptionForm/SubscriptionForm.module.css`:

\`\`\`css
.form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  max-width: 400px;
  margin: 0 auto;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.field label {
  font-weight: 600;
  color: #333;
}

.field input {
  padding: 0.75rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 1rem;
}

.field input:focus {
  outline: none;
  border-color: #0066cc;
  box-shadow: 0 0 0 3px rgba(0, 102, 204, 0.1);
}

.field input[aria-invalid="true"] {
  border-color: #d32f2f;
}

.error {
  color: #d32f2f;
  font-size: 0.875rem;
}

button {
  padding: 0.75rem 1.5rem;
  background-color: #0066cc;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  transition: background-color 0.2s;
}

button:hover:not(:disabled) {
  background-color: #0052a3;
}

button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

@media (max-width: 600px) {
  .form {
    max-width: 100%;
  }
}
\`\`\`

### Step 7: Unit Tests
Create `src/components/SubscriptionForm/SubscriptionForm.test.tsx`:

\`\`\`typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { SubscriptionForm } from './SubscriptionForm';

describe('SubscriptionForm', () => {
  it('renders form with inputs', () => {
    render(<SubscriptionForm onSubmit={jest.fn()} />);
    expect(screen.getByLabelText('Name')).toBeInTheDocument();
    expect(screen.getByLabelText('Email')).toBeInTheDocument();
  });

  it('submits form with valid data', async () => {
    const onSubmit = jest.fn().mockResolvedValue(undefined);
    render(<SubscriptionForm onSubmit={onSubmit} />);

    fireEvent.change(screen.getByLabelText('Name'), { target: { value: 'John' } });
    fireEvent.change(screen.getByLabelText('Email'), { target: { value: 'john@example.com' } });
    fireEvent.click(screen.getByRole('button', { name: /subscribe/i }));

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({ name: 'John', email: 'john@example.com' });
    });
  });

  it('shows validation errors', async () => {
    render(<SubscriptionForm onSubmit={jest.fn()} />);
    fireEvent.click(screen.getByRole('button', { name: /subscribe/i }));

    await waitFor(() => {
      expect(screen.getByText('Name is required')).toBeInTheDocument();
      expect(screen.getByText('Email is required')).toBeInTheDocument();
    });
  });

  it('shows loading state', () => {
    render(<SubscriptionForm onSubmit={jest.fn()} isLoading={true} />);
    expect(screen.getByRole('button')).toBeDisabled();
    expect(screen.getByRole('button')).toHaveAttribute('aria-busy', 'true');
  });

  it('displays submission error', async () => {
    const onSubmit = jest.fn().mockRejectedValue(new Error('Network error'));
    render(<SubscriptionForm onSubmit={onSubmit} />);

    fireEvent.change(screen.getByLabelText('Name'), { target: { value: 'John' } });
    fireEvent.change(screen.getByLabelText('Email'), { target: { value: 'john@example.com' } });
    fireEvent.click(screen.getByRole('button'));

    await waitFor(() => {
      expect(screen.getByText('Network error')).toBeInTheDocument();
    });
  });
});
\`\`\`

### Step 8: Documentation
Create `src/components/SubscriptionForm/README.md`:

\`\`\`markdown
# SubscriptionForm Component

Subscription form with validation, error handling, and accessibility.

## Props

- \`onSubmit\`: Async function to handle form submission
- \`isLoading\`: Optional boolean to show loading state

## Usage

\`\`\`tsx
<SubscriptionForm
  onSubmit={async (data) => {
    await api.subscribe(data);
  }}
  isLoading={false}
/>
\`\`\`

## Accessibility

- ARIA labels for all inputs
- Error messages associated with inputs
- Keyboard navigation support
- Loading state announced
\`\`\`

## Testing Requirements
- Component rendering: ✓
- Form submission: ✓
- Validation errors: ✓
- Loading state: ✓
- Error handling: ✓
- Accessibility: ✓
- Coverage: 80%+

## Accessibility Checklist
- [x] Labels for all inputs
- [x] ARIA attributes (aria-required, aria-invalid, aria-busy)
- [x] Keyboard navigation (Tab, Enter)
- [x] Color contrast (WCAG AA)
- [x] Screen reader compatible
- [x] Error messages announced

## Next Steps
Run: `develop-frontend @SCRUM-501_frontend.md`
```

## Output

Display:
```
## Plan Generated: SCRUM-501

**Feature**: Subscription Form Component
**Implementation Steps**: 8
**Estimated Effort**: Medium

**Component Structure**:
- SubscriptionForm (main)
- FormInput (reusable)
- ValidationMessage (error display)
- SubmitButton (with loading)

**State Management**: useState + useCallback

**Plan Location**: ai-specs/changes/SCRUM-501_frontend.md

**Next Command**:
develop-frontend @SCRUM-501_frontend.md
```
