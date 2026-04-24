---
name: maintain-data-model
description: Automatically extract entity definitions from .NET Domain layer and update ai-specs/specs/data-model.md with field definitions, relationships, and validation rules.
license: MIT
compatibility: Requires .NET 6, C# domain entities, ai-specs/specs/data-model.md
metadata:
  author: La Nación
  version: "1.0.0"
  standards:
    - ai-specs/specs/data-model.md
    - ai-specs/specs/documentation-standards.mdc
  agents:
    - lanacion-api-developer
    - lanacion-lstnr-developer
---

Automatically maintain `ai-specs/specs/data-model.md` by extracting entity definitions from the .NET Domain layer.

## Purpose

Keeps the data model documentation synchronized with domain entity implementations during feature development.

**When to use**: After implementing new domain entities or modifying existing ones. This skill is typically invoked as **Step 11 (Documentation)** of the backend implementation workflow.

## Responsibilities

This skill:

- ✅ Reads domain entity classes from `[Project].Domain/`
- ✅ Extracts class name, properties, data types, and nullable constraints
- ✅ Identifies validation rules from data annotations or inline validation
- ✅ Discovers relationships (foreign keys, navigation properties)
- ✅ Finds existing entity documentation in `ai-specs/specs/data-model.md`
- ✅ Updates or creates entity sections with extracted information
- ✅ Maintains markdown formatting and structure consistency
- ✅ Preserves manual documentation that doesn't conflict with extracted data

This skill does NOT:

- ❌ Modify domain entity code
- ❌ Generate migration scripts (use `implement-database-migration` for that)
- ❌ Create new fields or change types
- ❌ Replace business logic comments or custom documentation

## Workflow

### Input

The skill expects:

1. **Project path**: Location of the .NET project (e.g., `apps/MyProject.Api`)
2. **Domain namespace**: Namespace for domain entities (e.g., `MyProject.Domain.Entities`)
3. **Entities to document**: List of entity class names to extract and document

### Process

1. **Locate domain entities**
   - Navigate to `[Project].Domain/` folder
   - Find C# files containing entity classes

2. **Extract entity metadata**
   
   For each entity, parse:
   - Class name (becomes entity heading)
   - XML documentation or inline comments (description)
   - Public properties (fields definition)
   - Data types (string, int, DateTime, guid, etc.)
   - Nullable constraints (required vs. optional)
   - `[Required]`, `[MaxLength]`, `[EmailAddress]` attributes
   - Navigation properties (relationships)
   - Foreign key properties

   Example extraction:
   ```csharp
   /// <summary>Represents a customer subscription</summary>
   public class Subscription
   {
       [Required]
       [MaxLength(36)]
       public Guid Id { get; set; }
       
       [Required]
       [MaxLength(100)]
       public string PlanName { get; set; }
       
       [Range(0, 10000)]
       public decimal Price { get; set; }
       
       public DateTime? EndDate { get; set; }
       
       public Guid CustomerId { get; set; }
       public Customer Customer { get; set; } // navigation property
   }
   ```

   Extracts to documentation:
   - `Id`: Unique identifier (Primary Key), required, 36 characters max
   - `PlanName`: Plan name, required, 100 characters max
   - `Price`: Subscription price, range 0-10000
   - `EndDate`: End date (optional)
   - Relationship: `customer` - Many-to-one with Customer

3. **Generate markdown documentation**
   
   Create or update section in `data-model.md`:
   ```markdown
   ### [Entity Number]. Subscription
   
   Represents a customer subscription.
   
   **Fields:**
   - `id`: Unique identifier for the subscription (Primary Key)
   - `planName`: Plan name (max 100 characters)
   - `price`: Subscription price (range 0-10000)
   - `endDate`: End date (optional, null if ongoing)
   - `customerId`: Foreign key referencing the Customer
   
   **Validation Rules:**
   - Plan name is required and cannot exceed 100 characters
   - Price must be between 0 and 10000
   - End date is optional but must be valid if provided
   
   **Relationships:**
   - `customer`: Many-to-one relationship with Customer model
   ```

4. **Update data-model.md**
   
   - Search for existing entity section by name
   - If found: update fields, validation, and relationships sections
   - If not found: append new section at end
   - Preserve entity number from existing documentation
   - Maintain section ordering

5. **Verify and finalize**
   
   - Confirm all extracted fields are documented
   - Verify relationships reference existing entities
   - Check markdown syntax is valid
   - Ensure English language and documentation standards

### Output

Updated `ai-specs/specs/data-model.md` with:
- New entity sections for created classes
- Updated field documentation for modified entities
- Current validation rules extracted from attributes
- Relationship definitions based on navigation properties

## Integration with Implementation Workflow

This skill is designed to integrate as **Step 11: Update Documentation** in `implement-backend-plan`:

```
Step 11/11: Update Documentation
├── API Endpoint Documentation (Update api-spec.yml)
├── Data Model Documentation (maintain-data-model skill)
└── Other relevant documentation
```

When invoked after implementing a feature:

1. Feature implementation completes (Steps 1-10)
2. `maintain-data-model` is triggered for each new/modified entity
3. `data-model.md` is automatically synchronized
4. Manual verification required for business logic descriptions

## Usage Example

**Input**:
```
Project: apps/Suscripciones.Api
Entities: [Suscripcion, Plan, Cliente]
```

**Processing**:
- Reads `Suscripciones.Domain/Entities/Suscripcion.cs`
- Extracts fields, types, validation
- Updates or creates section in `data-model.md`
- Repeats for Plan and Cliente

**Output**:
Updated `ai-specs/specs/data-model.md` with three new or updated entity sections.

## Limitations & Notes

- Only documents public properties; private fields are ignored
- Requires valid C# syntax and DataAnnotation attributes
- Complex types (nested classes, generics) must be manually documented
- Business logic documentation is preserved and not overwritten
- Does not generate Entity-Relationship Diagram (ERD) - manual update required
- Requires `documentation-standards.mdc` compliance for writing style

## Future Enhancements

- Auto-generate Entity-Relationship Diagram (Mermaid)
- Extract database column metadata from Dapper base repository
- Validate relationship references against existing entities
- Generate TypeScript interface definitions from entities
