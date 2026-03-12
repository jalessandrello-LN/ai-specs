# Comandos La Nación

Comandos especializados para desarrollo backend con templates de La Nación (.NET 6).

## 📋 Comandos Disponibles

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

## 🎯 Flujos de Trabajo Típicos

### Crear API REST Completa

```bash
# 1. Crear repositorio
/create-repository Producto MySQL

# 2. Crear comando para crear producto
/create-api-command Create Producto "Crear nuevo producto con nombre y precio"

# 3. Crear query para obtener producto
/create-api-query Get Producto "Obtener producto por ID"

# 4. (Opcional) Integrar servicio legacy
/integrate-wcf-service InventarioService GetStock https://legacy.svc?wsdl
```

### Crear Listener Completo

```bash
# 1. Crear listener completo (incluye repositorio)
dotnet new ln-SQSlstnr -n OrderListener
/create-sqs-listener Order_Created order-processing Order MySQL

# 2. Configurar SQS
/configure-sqs order-processing Order_Created Development

# 3. Agregar health checks
/add-health-checks OrderService Database,SQS
```

### Agregar Evento a Listener Existente

```bash
# Agregar evento de actualización
/add-event Order_Updated order-updates "Actualizar estado de orden"

# Configurar nueva cola
/configure-sqs order-updates Order_Updated Development
```

## 📚 Referencias

- **Estándares Listener**: `ai-specs/specs/ln-susc-listener-standards.mdc`
- **Estándares API**: `ai-specs/specs/ln-susc-api-standards.mdc`
- **Agente Listener**: `ai-specs/.agents/lanacion-lstnr-developer.md`
- **Agente API**: `ai-specs/.agents/lanacion-api-developer.md`

## 🔗 Comandos Relacionados

- `/plan-backend-ticket` - Planificar implementación backend
- `/develop-backend` - Implementar plan backend
- `/commit` - Crear commit descriptivo

## 📖 Documentación Adicional

Para detalles completos sobre arquitectura, patrones y mejores prácticas, consultar:
- `ai-specs/specs/ln-susc-listener-standards.mdc`
- `ai-specs/specs/ln-susc-api-standards.mdc`
