# SIMULACIÓN 2: Requerimiento de Listener SQS

## Entrada del Usuario
```
/plan-listener-ticket HU-202
```

**Descripción del Ticket HU-202:**
- Procesar eventos de cambio de estado de cobro
- Cola: `suscripciones-prod-sqs-cobros-resultado`
- Evento: `evt-cobros-pago-procesado`
- Implementar idempotencia con tabla `MensajesRecibidos`
- Actualizar estado en base de datos
- Registrar en tabla de auditoría

## Flujo Esperado

### Paso 1: Clasificación
- ✅ Agente: `lanacion-backend-planner`
- ✅ Tipo detectado: **Listener** (procesamiento de eventos SQS)
- ✅ Estándar: `ln-susc-listener-standards.mdc`

### Paso 2: Generación de Plan
- ✅ Archivo generado: `ai-specs/changes/HU-202_backend.md`
- ✅ Prefijo de ticket: **HU-202** ✅
- ✅ Estructura: Domain (Event) → Application (Processor) → Infrastructure → Worker → Tests

### Paso 3: Validación de Coherencia
- ✅ Plan incluye: Event, Processor, Validator, Repository, Worker Config
- ✅ Idempotencia implementada con MensajesRecibidos
- ✅ ProcessResult handling correcto
- ✅ Cobertura de tests: 80%+

## Resultado Esperado
```
✅ Plan generado: ai-specs/changes/HU-202_backend.md
✅ Prefijo correcto: HU-202
✅ Tipo: Listener
✅ Estándar aplicado: ln-susc-listener-standards.mdc
✅ Idempotencia: Incluida
```
