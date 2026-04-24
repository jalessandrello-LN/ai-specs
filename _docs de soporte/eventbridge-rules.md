# EventBridge Rules y Event Patterns - Suscripciones Ecosystem

**Actualizado:** 22 de Enero, 2026

---

## Overview

EventBridge es el bus de eventos central del ecosistema de Suscripciones. Utiliza **reglas declarativas** basadas en patrones para enrutar eventos publicados a sus destinos correspondientes (colas SQS, Lambdas, etc.).

---

## Modelo de Routing: detail-type Pattern

### Patrón General

```json
{
  "detail-type": ["EventType1", "EventType2", ...]
}
```

El campo `detail-type` es el atributo clave utilizado para clasificar y enrutar eventos en EventBridge. Cada evento debe incluir este campo en su estructura.

---

## Event Types Definidos

### 1. VentasAlta

**Propósito:** Eventos relacionados con altas de ventas/suscripciones

| Propiedad | Valor |
|-----------|-------|
| **DetailType** | `VentasAlta` |
| **EventBridge Pattern** | `{"detail-type":["VentasAlta"]}` |
| **Target Queue** | `suscripciones-{env}-sqs-ventas-alta` |
| **DLQ** | `suscripciones-{env}-sqs-ventas-alta_dlq` |
| **Source Microservice** | `suscripciones-api` |
| **Consumer** | `ventas-listener` |

**Estructura de Evento:**
```json
{
  "DetailType": "VentasAlta",
  "Source": "suscripciones-api",
  "EventBusName": "suscripciones-{env}-eventbridge-main",
  "Detail": {
    "subscriptionId": "sub-123456",
    "customerId": "cust-789",
    "planType": "premium",
    "startDate": "2026-01-22",
    "bundleIds": ["bundle-001", "bundle-002"]
  }
}
```

---

### 2. CobranzasResultado

**Propósito:** Eventos con resultados de cobros y transacciones

| Propiedad | Valor |
|-----------|-------|
| **DetailType** | `CobranzasResultado` |
| **EventBridge Pattern** | `{"detail-type":["CobranzasResultado"]}` |
| **Target Queue** | `suscripciones-{env}-sqs-cobranzas-resultado` |
| **DLQ** | `suscripciones-{env}-sqs-cobranzas-resultado_dlq` |
| **Source Microservice** | `cobranzas-listener` |
| **Consumer** | `suscripciones-api` |

**Estructura de Evento:**
```json
{
  "DetailType": "CobranzasResultado",
  "Source": "cobranzas-listener",
  "EventBusName": "suscripciones-{env}-eventbridge-main",
  "Detail": {
    "transactionId": "trx-456789",
    "subscriptionId": "sub-123456",
    "amount": 99.99,
    "currency": "ARS",
    "status": "SUCCESS",
    "paymentMethod": "credit_card",
    "processedAt": "2026-01-22T14:30:00Z"
  }
}
```

---

### 3. FacturacionCambio

**Propósito:** Eventos de cambios en facturación y modificaciones de suscripciones

| Propiedad | Valor |
|-----------|-------|
| **DetailType** | `FacturacionCambio` |
| **EventBridge Pattern** | `{"detail-type":["FacturacionCambio"]}` |
| **Target Queue** | `suscripciones-{env}-sqs-facturacion-cambio` |
| **DLQ** | `suscripciones-{env}-sqs-facturacion-cambio_dlq` |
| **Source Microservice** | `facturacion-listener` |
| **Consumer** | `suscripciones-api` |

**Estructura de Evento:**
```json
{
  "DetailType": "FacturacionCambio",
  "Source": "facturacion-listener",
  "EventBusName": "suscripciones-{env}-eventbridge-main",
  "Detail": {
    "subscriptionId": "sub-123456",
    "changeType": "PLAN_UPGRADE",
    "oldPlan": "basic",
    "newPlan": "premium",
    "effectiveDate": "2026-01-22",
    "invoiceNumber": "INV-2026-001234"
  }
}
```

---

## Configuración de Reglas en EventBridge

### Creación de Regla (AWS CLI)

```bash
# Crear regla para VentasAlta
aws events put-rule \
  --name suscripciones-{env}-rule-ventas-alta \
  --event-bus-name suscripciones-{env}-eventbridge-main \
  --event-pattern '{"detail-type":["VentasAlta"]}'

# Crear regla para CobranzasResultado
aws events put-rule \
  --name suscripciones-{env}-rule-cobranzas-resultado \
  --event-bus-name suscripciones-{env}-eventbridge-main \
  --event-pattern '{"detail-type":["CobranzasResultado"]}'

# Crear regla para FacturacionCambio
aws events put-rule \
  --name suscripciones-{env}-rule-facturacion-cambio \
  --event-bus-name suscripciones-{env}-eventbridge-main \
  --event-pattern '{"detail-type":["FacturacionCambio"]}'
```

### Agregar Targets (AWS CLI)

```bash
# Agregar SQS como target a la regla
aws events put-targets \
  --rule suscripciones-{env}-rule-ventas-alta \
  --event-bus-name suscripciones-{env}-eventbridge-main \
  --targets "Id"="1","Arn"="arn:aws:sqs:us-east-1:ACCOUNT_ID:suscripciones-{env}-sqs-ventas-alta"
```

---

## Configuración en CDK TypeScript

### Event Pattern en CDK

```typescript
// En suscripciones-infrastructure-stack.ts
new events.Rule(this, `${queueName}Rule`, {
  eventBus: eventBus,
  ruleName: `suscripciones-${environment}-rule-${queueName}`,
  eventPattern: {
    detailType: [this.getDetailTypeForQueue(queueName)]
  },
  targets: [new cdk.aws_events_targets.SqsQueue(queue)]
});

// Mapeo de detail types
private getDetailTypeForQueue(queueName: string): string {
  const detailTypeMap: { [key: string]: string } = {
    'ventas-alta': 'VentasAlta',
    'cobranzas-resultado': 'CobranzasResultado',
    'facturacion-cambio': 'FacturacionCambio'
  };
  return detailTypeMap[queueName] || queueName;
}
```

---

## Flujo de Publicación de Eventos

### Desde el Microservicio

```csharp
// En un Command Handler
public async Task<Result> Handle(CreateSubscriptionCommand request, CancellationToken cancellationToken)
{
    // Crear suscripción
    var subscription = new Subscription(...);
    
    // Publicar evento con DetailType
    var @event = new SubscriptionCreatedDomainEvent(
        subscriptionId: subscription.Id,
        customerId: request.CustomerId,
        planType: request.PlanType
    );
    
    // El Outbox Publisher captura esto y lo serializa
    // Luego se publica a EventBridge con DetailType = "VentasAlta"
    await _eventPublisher.PublishAsync(@event);
    
    return Result.Success();
}
```

### Consumo desde SQS

```csharp
// El SqsQueueConsumerService escucha de la cola
// Deserializa el evento y lo procesa
public async Task ProcessMessageAsync(SubscriptionCreatedDomainEvent @event)
{
    // Lógica de negocio
    await _handler.Handle(@event, cancellationToken);
}
```

---

## Validación de Eventos

### Checklist de Publicación

- ✅ Evento incluye campo `DetailType` con valor válido
- ✅ Evento está serializado correctamente a JSON
- ✅ EventBusName es correcto: `suscripciones-{env}-eventbridge-main`
- ✅ Campo `Source` indica el microservicio origen
- ✅ Campo `Detail` contiene datos del evento
- ✅ DetailType coincide con uno de los Event Types definidos

### Validación de Routing

```bash
# Verificar que la regla está activa
aws events list-rules \
  --event-bus-name suscripciones-{env}-eventbridge-main \
  --profile localstack

# Ver targets de una regla
aws events list-targets-by-rule \
  --rule suscripciones-{env}-rule-ventas-alta \
  --event-bus-name suscripciones-{env}-eventbridge-main \
  --profile localstack
```

---

## Dead Letter Queue (DLQ) Handling

Si un evento no se puede procesar después de 3 intentos:

1. Se envía automáticamente a la DLQ correspondiente
2. Disponible en: `suscripciones-{env}-sqs-{type}_dlq`
3. Retención de 14 días para análisis
4. Requiere análisis manual para reprocesamiento

```bash
# Consumir de DLQ
aws sqs receive-message \
  --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/suscripciones-local-sqs-ventas-alta_dlq \
  --profile localstack \
  --max-number-of-messages 10
```

---

## Troubleshooting

### Evento no llega a la cola

1. **Verificar DetailType**: ¿Es uno de los valores válidos?
2. **Verificar EventBusName**: ¿Es correcto?
3. **Verificar regla está activa**: `aws events list-rules`
4. **Ver targets**: `aws events list-targets-by-rule`
5. **Revisar logs**: CloudWatch en la región correcta

### Evento en DLQ

1. Revisar los logs del listener
2. Verificar estructura del evento
3. Verificar permisos de IAM
4. Verificar estado de la cola SQS

---

## Migraciones Futuras

Si necesitas agregar nuevos Event Types:

1. Define el nuevo `DetailType`
2. Crea la regla en EventBridge con el patrón correspondiente
3. Agrega el target SQS
4. Actualiza la documentación
5. Actualiza `getDetailTypeForQueue()` en CDK si corresponde
6. Implementa el listener consumer

---

## Referencias

- [LOCALSTACK-RECURSOS.md](./infrastructure/cdk/LOCALSTACK-RECURSOS.md)
- [EVENT-TYPES.md](./infrastructure/cdk/EVENT-TYPES.md)
- [architecture-1.solution-architecture.md](./Docs iniciales/architecture-1.solution-architecture.md)

