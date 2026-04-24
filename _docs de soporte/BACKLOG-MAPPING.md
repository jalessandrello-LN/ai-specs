# Backlog: Subscription Management Feature Backlog

**Generated from**: `Funcional-spec-dd.md`
**Date**: April 16, 2026
**Project**: LaNacion Subscriptions Module Reengineering

---

## Epic: Subscription Lifecycle Management

**ID**: EPIC-001
**Name**: subscription-lifecycle
**Description**: Complete lifecycle management for subscriptions including creation, modification, suspension, and cancellation.

### MVP: Subscription Core Operations

#### HU-001: Create Subscription
```bash
/openspec new change "create-subscription" --schema hu
```

**Source**: `Funcional-spec-dd.md` Section 5 - "Alta de Suscripción"

**Acceptance Criteria**:
- Receive subscription creation event from external sales system
- Validate required data (customer, plan, dates)
- Create subscription with initial state
- Generate subscription number (format: SUB-YYYYMM-XXXXXX)
- Create CondicionComercial snapshot from PlanDeVenta
- Publish evt-susc-suscripcion-creada event
- Support trial period handling

**Technical Type**: Listener (SQS event processor)

---

#### HU-002: Cancel Subscription
```bash
/openspec new change "cancel-subscription" --schema hu
```

**Source**: `Funcional-spec-dd.md` Section 5 - "Baja de Suscripción"

**Acceptance Criteria**:
- Process cancellation request (internal or external)
- Validate subscription exists and can be cancelled
- Update subscription state to "Baja"
- Record cancellation reason and date
- Generate novelty for affected systems
- Notify Billing (SAP), Logistics, Benefits

**Technical Type**: Listener (SQS event processor)

---

#### HU-003: Suspend Subscription
```bash
/openspec new change "suspend-subscription" --schema hu
```

**Source**: `Funcional-spec-dd.md` Section 2.1 - "Gestión de Suscripciones"

**Acceptance Criteria**:
- Process suspension due to payment failure or vacation
- Update subscription state to "Suspendida"
- Record suspension reason and dates
- Generate novelty for downstream systems
- Notify Billing and Benefits

**Technical Type**: Listener (SQS event processor)

---

#### HU-004: Rehabilitate Subscription
```bash
/openspec new change "rehabilitate-subscription" --schema hu
```

**Source**: `Funcional-spec-dd.md` Section 2.1 - "Gestión de Suscripciones"

**Acceptance Criteria**:
- Process payment success notification
- Update subscription state to "Activa"
- Calculate next billing date
- Generate novelty for downstream systems
- Notify Billing and Benefits

**Technical Type**: Listener (SQS event processor)

---

### MVP: Subscription Query API

#### HU-010: Query Subscription by ID
```bash
/openspec new change "get-subscription" --schema hu
```

**Source**: Internal operational needs

**Acceptance Criteria**:
- GET /api/v1/suscripciones/{id}
- Return full subscription details including:
  - Customer info
  - Plan info
  - Current CondicionComercial version
  - Subscription products
  - Billing history

**Technical Type**: API (REST endpoint)

---

#### HU-011: List Customer Subscriptions
```bash
/openspec new change "list-customer-subscriptions" --schema hu
```

**Source**: Internal operational needs

**Acceptance Criteria**:
- GET /api/v1/clientes/{id}/suscripciones
- Support pagination and filtering by state
- Return summary list with key fields

**Technical Type**: API (REST endpoint)

---

#### HU-012: Search Subscriptions
```bash
/openspec new change "search-subscriptions" --schema hu
```

**Source**: Internal operational needs

**Acceptance Criteria**:
- GET /api/v1/suscripciones
- Support filters: estado, fechaAlta, planId
- Support pagination
- Return matching subscriptions

**Technical Type**: API (REST endpoint)

---

### MVP: Subscription Modification

#### HU-020: Change Subscription Product
```bash
/openspec new change "change-subscription-product" --schema hu
```

**Source**: `Funcional-spec-dd.md` Section 2.1 - "Cambios de Productos"

**Acceptance Criteria**:
- Accept product change request
- Validate new product is compatible
- If within bundle: update bundle composition
- Generate new CondicionComercial version for affected subscriptions
- Record change in novelty/history
- Notify downstream systems

**Technical Type**: Listener (SQS event processor)

---

#### HU-021: Change Subscription Plan
```bash
/openspec new change "change-subscription-plan" --schema hu
```

**Source**: `Funcional-spec-dd.md` Section 2.1 - "Cambios de Planes de Venta"

**Acceptance Criteria**:
- Accept plan change request
- Validate new plan is valid
- Generate new CondicionComercial version
- Recalculate pricing if needed
- Notify downstream systems

**Technical Type**: Listener (SQS event processor)

---

#### HU-022: Update Subscription Address
```bash
/openspec new change "update-subscription-address" --schema hu
```

**Source**: Internal operational needs

**Acceptance Criteria**:
- Update delivery address
- Generate novelty for Logistics
- Support multiple addresses per subscription

**Technical Type**: API (REST endpoint)

---

### MVP: Subscription Notifications

#### HU-030: Subscription State Change Notifier
```bash
/openspec new change "subscription-state-events" --schema hu
```

**Source**: `Funcional-spec-dd.md` Section 2.1 - "Notificación Events"

**Acceptance Criteria**:
- Publish events for all state changes
- Events: evt-susc-suscripcion-creada, evt-susc-suscripcion-suspendida, etc.
- Include full context in event payload
- Route to appropriate EventBridge bus

**Technical Type**: Internal (Outbox Pattern in other HUs)

---

## Epic: Bundle Management

**ID**: EPIC-002
**Name**: bundle-management
**Description**: Management of subscription bundles including creation, composition updates, and version control.

### MVP: Bundle Core

#### HU-100: Create Bundle
```bash
/openspec new change "create-bundle" --schema hu
```

**Source**: `Funcional-spec-dd.md` Section 2.1 - "Gestión de Bundles"

**Acceptance Criteria**:
- Receive bundle creation from sales system
- Create bundle with initial subscriptions
- Generate bundle number
- Record initial composition
- Link to customer
- Notify downstream systems

**Technical Type**: Listener (SQS event processor)

---

#### HU-101: Update Bundle Composition
```bash
/openspec new change "update-bundle-composition" --schema hu
```

**Source**: `Funcional-spec-dd.md` Section 2.1 - "Cambios de Composición"

**Acceptance Criteria**:
- Add/remove subscriptions from bundle
- Require authorization/signature for changes
- Generate new composition version
- Update CondicionComercial for all affected subscriptions
- Record in composition history
- Notify affected systems

**Technical Type**: Listener (SQS event processor)

---

#### HU-102: Query Bundle
```bash
/openspec new change "get-bundle" --schema hu
```

**Source**: Internal operational needs

**Acceptance Criteria**:
- GET /api/v1/bundles/{id}
- Return bundle with all subscriptions
- Include composition history

**Technical Type**: API (REST endpoint)

---

## Epic: Commercial Conditions

**ID**: EPIC-003
**Name**: commercial-conditions
**Description**: Versioning and management of commercial conditions for subscriptions.

### MVP: Condition Versioning

#### HU-200: Create Condition Snapshot
```bash
/openspec new change "create-condition-snapshot" --schema hu
```

**Source**: `Funcional-spec-dd.md` Section 2.1 - "Versionado de Condiciones Comerciales"

**Acceptance Criteria**:
- Snapshot PlanDeVenta conditions on subscription creation
- Create immutable CondicionComercial record
- Link to subscription
- Record creation timestamp and reason

**Technical Type**: Internal (part of HU-001)

---

#### HU-201: Apply Condition Update
```bash
/openspec new change "apply-condition-update" --schema hu
```

**Source**: `Funcional-spec-dd.md` Section 2.1 - "Versionado de Condiciones Comerciales"

**Acceptance Criteria**:
- Generate new CondicionComercial version on changes
- Preserve previous versions for audit
- Apply to all affected subscriptions (bundle scope)
- Include version reference in novelty

**Technical Type**: Listener (SQS event processor)

---

#### HU-202: Query Condition History
```bash
/openspec new change "get-condition-history" --schema hu
```

**Source**: Internal operational needs

**Acceptance Criteria**:
- GET /api/v1/suscripciones/{id}/condiciones
- Return all versions with timestamps
- Support date range filtering

**Technical Type**: API (REST endpoint)

---

## Epic: Billing Integration

**ID**: EPIC-004
**Name**: billing-integration
**Description**: Integration with billing systems for invoicing and payment processing.

### MVP: Payment Processing

#### HU-300: Process Payment Success
```bash
/openspec new change "process-payment-success" --schema hu
```

**Source**: `Funcional-spec-dd.md` Section 4 - "Gestor de Cobranzas"

**Acceptance Criteria**:
- Receive payment success event
- Update subscription to Activa if was Pendiente
- Calculate next billing date
- Generate novelty for record keeping
- Log payment reference

**Technical Type**: Listener (SQS event processor)

---

#### HU-301: Process Payment Failure
```bash
/openspec new change "process-payment-failure" --schema hu
```

**Source**: `Funcional-spec-dd.md` Section 4 - "Gestor de Cobranzas"

**Acceptance Criteria**:
- Receive payment failure event
- Track failure count
- Trigger suspension after threshold
- Generate novelty for downstream systems

**Technical Type**: Listener (SQS event processor)

---

## Sprint Planning Example

### Sprint 1: Foundation

```bash
# HU-001: Create Subscription (MVP core)
/openspec new change "create-subscription" --schema hu
/openspec continue proposal --change "create-subscription"
/openspec continue design --change "create-subscription"
/openspec continue tasks --change "create-subscription"
/plan-backend-ticket create-subscription
/develop-backend @create-subscription_backend.md
/openspec verify change "create-subscription"
/openspec archive change "create-subscription"

# HU-010: Query Subscription (API foundation)
/openspec new change "get-subscription" --schema hu
/openspec continue proposal --change "get-subscription"
/openspec continue design --change "get-subscription"
/openspec continue tasks --change "get-subscription"
/plan-backend-ticket get-subscription
/develop-backend @get-subscription_backend.md
/openspec verify change "get-subscription"
/openspec archive change "get-subscription"
```

### Sprint 2: Lifecycle

```bash
# HU-002: Cancel Subscription
# HU-003: Suspend Subscription
# HU-004: Rehabilitate Subscription
# HU-011: List Customer Subscriptions
```

### Sprint 3: Bundles

```bash
# HU-100: Create Bundle
# HU-101: Update Bundle Composition
# HU-102: Query Bundle
```

---

## Use Case → HU Mapping

| Use Case (Funcional-spec) | HU ID | Type | Priority |
|--------------------------|-------|------|----------|
| Alta de Suscripción | HU-001 | Listener | P0 |
| Baja de Suscripción | HU-002 | Listener | P0 |
| Suspensiones/Rehabilitaciones | HU-003, HU-004 | Listener | P0 |
| Cambio de Producto | HU-020 | Listener | P1 |
| Cambio de Plan | HU-021 | Listener | P1 |
| Gestión de Bundles | HU-100, HU-101 | Listener | P1 |
| Versionado Condiciones | HU-200, HU-201 | Internal | P1 |
| APIs de Consulta | HU-010, HU-011, HU-012 | API | P0 |
| Integración Cobranzas | HU-300, HU-301 | Listener | P0 |

---

## Notes

- **P0**: Must have for MVP
- **P1**: Important for full release
- **P2**: Nice to have

All Listener HUs follow the idempotent SQS pattern.
All API HUs follow REST conventions with CQRS.
