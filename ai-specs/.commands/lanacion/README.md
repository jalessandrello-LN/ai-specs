# Comandos La Nación

Comandos especializados para desarrollo backend con templates de La Nación (.NET 6).

## 📋 Comandos Disponibles

### Planificación

#### `/plan-backend-ticket` *(en `.commands/`)*
Genera plan de implementación para un ticket de API REST.
```
/plan-backend-ticket [TicketId]
```

#### `/plan-listener-ticket`
Genera plan de implementación para un ticket de listener SQS.
```
/plan-listener-ticket [TicketId]
```
**Genera**: `ai-specs/changes/[TicketId]_backend.md` especializado en eventos, idempotencia y ProcessResult
**Agente**: `lanacion-backend-planner`

### Monorepo (Scaffold)

#### `/scaffold-api`
Scaffoldea una nueva Minimal API en el monorepo.
```
/scaffold-api [ProjectName] [HttpPort?] [HttpsPort?] [OrderRelease?]
```
**Skill**: `scaffold-monorepo-backend-app` + `validate-monorepo-integration`

#### `/scaffold-listener`
Scaffoldea un nuevo listener SQS en el monorepo.
```
/scaffold-listener [ProjectName] [OrderRelease?]
```
**Skill**: `scaffold-monorepo-backend-app` + `validate-monorepo-integration`

#### `/scaffold-lambda`
Scaffoldea una nueva Lambda .NET 8 en el monorepo.
```
/scaffold-lambda [LambdaName] [StackName?] [MemorySize?] [OrderRelease?]
```
**Skill**: `scaffold-monorepo-lambda` + `validate-monorepo-integration`

#### `/validate-monorepo`
Valida la integración de un proyecto en el monorepo.
```
/validate-monorepo [ProjectName] [ArtifactType?]
```
**Skill**: `validate-monorepo-integration`

### REST APIs

#### `/create-api-command`
Crea endpoint completo que modifica estado (Command/Mutation).
```
/create-api-command [Action] [Entity] [Description]
```
**Genera**: Command, Validator, Handler (con UoW + Event Publishing), Endpoint
**Referencia**: `ln-susc-api-standards.mdc`

#### `/create-api-query`
Crea endpoint completo de solo lectura (Query).
```
/create-api-query [Action] [Entity] [Description]
```
**Genera**: Query, DTO, Handler (sin transacciones), Endpoint
**Referencia**: `ln-susc-api-standards.mdc`

#### `/create-api-endpoint`
Crea solo el `IEndpointDefinition` para un command/query ya existente.
```
/create-api-endpoint [HttpMethod] [Entity] [CommandOrQuery] [Route?]
```
**Genera**: `{Entity}Endpoints.cs` con el método HTTP y status codes correctos

#### `/integrate-wcf-service`
Integra servicio WCF SOAP legacy con Adapter Pattern.
```
/integrate-wcf-service [ServiceName] [Operation] [WsdlUrl]
```
**Genera**: Interface pura, Adapter, AutoMapper profile, DI configuration
**Referencia**: `ln-susc-api-standards.mdc`

### SQS Listeners

#### `/create-sqs-listener`
Genera un listener SQS completo con template `ln-SQSlstnr`.
```bash
dotnet new ln-SQSlstnr -n [ProjectName]
```
**Referencia**: `ln-susc-listener-standards.mdc`

#### `/add-event`
Agrega un nuevo evento y handler a listener existente.
```
/add-event [EventName] [QueueName] [HandlerLogic?]
```

#### `/add-idempotency-check`
Agrega el patrón de idempotencia (MensajesRecibidos) a un processor existente.
```
/add-idempotency-check [ProcessorClass] [EventClass]
```
**Modifica**: constructor, Handle, DI registration; agrega tests de idempotencia

#### `/configure-sqs`
Configura cola SQS por ambiente.
```
/configure-sqs [QueueName] [EventType] [Environment]
```

#### `/add-health-checks`
Genera health checks con múltiples dependencias.
```
/add-health-checks [ServiceName] [Dependencies]
```

### Repositorios (Compartido)

#### `/create-repository`
Genera repositorio completo con entidad, interface e implementación.
```
/create-repository [EntityName] [DatabaseType]
```

**Cuándo usar**:
- **En APIs**: Cuando el repositorio no existe
- **En Listeners**: Generalmente NO necesario (ya incluido en `create-sqs-listener`)
- **Excepción**: Listener necesita repositorio adicional

### Calidad

#### `/cleanup-template-boilerplate`
Elimina código de ejemplo del template no relacionado con la HU actual.
```
/cleanup-template-boilerplate [ProjectPath] [HuScope?]
```
**Cuándo usar**: como último paso antes de hacer commit, en APIs y listeners

## 🎯 Flujos de Trabajo Típicos

### Crear API REST desde cero (monorepo)

```bash
# 1. Scaffoldear en el monorepo
/scaffold-api LN.Sus.Cobros.Api 5010 5011 10

# 2. Planificar el ticket
/plan-backend-ticket HU-10

# 3. Implementar (command + query + endpoint)
/create-repository Cobro MySQL
/create-api-command Create Cobro "Registrar nuevo cobro"
/create-api-query Get Cobro "Obtener cobro por ID"

# 4. Limpiar boilerplate
/cleanup-template-boilerplate apps/LN.Sus.Cobros.Api "gestión de cobros"
```

### Crear Listener SQS desde cero (monorepo)

```bash
# 1. Scaffoldear en el monorepo
/scaffold-listener LN.Sus.Ventas.Listener 20

# 2. Planificar el ticket
/plan-listener-ticket HU-42

# 3. Agregar evento y configurar
/add-event Venta_Registrada ventas-alta "Persistir venta y notificar"
/add-idempotency-check Venta_RegistradaProcessor Venta_Registrada
/configure-sqs ventas-alta Venta_Registrada Development

# 4. Limpiar boilerplate
/cleanup-template-boilerplate apps/LN.Sus.Ventas.Listener "procesamiento de ventas"
```

### Crear Lambda desde cero (monorepo)

```bash
# 1. Scaffoldear Lambda
/scaffold-lambda LN.Sus.Cobros.Procesador MiStack 512 30

# 2. Validar integración
/validate-monorepo LN.Sus.Cobros.Procesador lambda
```

### Agregar Evento a Listener Existente

```bash
/add-event Order_Updated order-updates "Actualizar estado de orden"
/add-idempotency-check Order_UpdatedProcessor Order_Updated
/configure-sqs order-updates Order_Updated Development
```

## 📚 Referencias

- **Estándares Listener**: `ai-specs/specs/ln-susc-listener-standards.mdc`
- **Estándares API**: `ai-specs/specs/ln-susc-api-standards.mdc`
- **Agente Listener**: `ai-specs/.agents/lanacion-lstnr-developer.md`
- **Agente API**: `ai-specs/.agents/lanacion-api-developer.md`
- **Agente Monorepo**: `ai-specs/.agents/lanacion-nx-monorepo-developer.md`
- **Agente Planner**: `ai-specs/.agents/lanacion-backend-planner.md`

## 🔗 Comandos Relacionados

- `/plan-backend-ticket` - Planificar implementación de API
- `/plan-listener-ticket` - Planificar implementación de listener
- `/develop-backend` - Implementar plan backend
- `/commit` - Crear commit descriptivo

## 📖 Documentación Adicional

Para detalles completos sobre arquitectura, patrones y mejores prácticas, consultar:
- `ai-specs/specs/ln-susc-listener-standards.mdc`
- `ai-specs/specs/ln-susc-api-standards.mdc`
