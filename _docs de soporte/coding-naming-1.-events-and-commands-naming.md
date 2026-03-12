## 1. Introducción
Este documento establece las convenciones de nomenclatura para eventos y comandos para arquitecturas basadas en eventos.

## 2. Definiciones

### 2.1 Comando
Un **comando** representa una intención o solicitud para que el sistema ejecute una acción. Los comandos:

* Expresan una orden o instrucción  
* Pueden ser rechazados si no cumplen validaciones  
* **Son procesados por un único handler**  
* **Modifican el estado del sistema**  
* Generan uno o más eventos como resultado  

**Finalidad en la arquitectura:**

- Encapsular la lógica de negocio  
- Validar reglas antes de ejecutar cambios  
- Mantener la intención del usuario/sistema  
- Proveer un punto de entrada controlado para operaciones  

### 2.2 Evento
Un **evento** representa un hecho que ya ocurrió en el sistema. Los eventos:

* **Describen algo que sucedió en el pasado**  
* **Sirven para notificar cambios de estado**  
* Son inmutables, no pueden ser rechazados  
* **Pueden ser consumidos por múltiples suscriptores**  
* Permiten reconstruir el estado del sistema (event sourcing — no es nuestro caso hoy, no tenemos soluciones que implementan event sourcing)  

**Finalidad en la arquitectura:**

- Desacoplar componentes del sistema  
- Notificar a sistemas externos  
- Habilitar procesamiento asíncrono  
- Facilitar la integración entre bounded contexts  

## 3. Principios Generales

* **Claridad**: Los nombres deben ser autoexplicativos  
* **Consistencia**: Seguir siempre el mismo patrón  
* **Idioma**: Castellano para entidades y verbos  
* **Tiempo verbal**: Comandos en infinitivo, eventos en pasado  
* **Formato**: Minúsculas con guiones como separadores (kebab-case)  

## 4. Comandos

### 4.1 Estructura

```text
cmd-{verbo}-{entidad}-{complemento?}
```
### 4.2 Formato
* Prefijo: `cmd-`
* Verbo en infinitivo
* Entidad en singular
* Palabras en minúsculas separadas por guiones

### 4.3 Ejemplos
```text
cmd-crear-suscripcion
cmd-actualizar-estado-suscripcion
cmd-cancelar-bundle
cmd-aplicar-descuento-retencion
cmd-suspender-suscripcion
cmd-reactivar-suscripcion
cmd-cambiar-plan-suscripcion
cmd-agregar-producto-bundle
cmd-remover-producto-bundle
cmd-procesar-ciclo-facturacion
cmd-generar-datos-factura
cmd-enviar-lote-cobranza
cmd-actualizar-condiciones-comerciales
cmd-registrar-resultado-pago
```
## 5. Eventos

### 5.1 Estructura
```text
evt-{squad-origen}-{entidad}-{verbo-pasado}
```
### 5.2 Formato

* Prefijo: `evt-`
* Abreviaciones de Squads (máximo 4 letras), por ejemplo:  
    * back-suscripciones → **susc**  
    * experiencias → **exp**  
    * maximizacion → **maxi**
* Entidad en singular
* Verbo en pasado participio
* Palabras en minúsculas separadas por guiones

### 5.3 Ejemplos

```text
evt-susc-suscripcion-creada
evt-susc-bundle-actualizado
evt-maxi-descuento-aplicado
evt-maxi-retencion-procesada
evt-exp-usuario-registrado
evt-exp-preferencias-actualizadas
```
## 6. Convenciones Adicionales

### 6.1 Versionado

Para cambios en la estructura:

```text
evt-susc-suscripcion-creada-v2
evt-susc-suscripcion-creada-v3
```
## 7. Enrutamiento en EventBridge (detail-type)

### 7.1 Mapping de Eventos a detail-type

Los eventos de dominio son mapeados a `detail-type` en EventBridge para enrutamiento basado en patrones. Cada evento debe incluir este campo en su estructura cuando se publica a EventBridge.

**Mapeo de Eventos Principales:**

| Evento de Dominio | Detail-Type EventBridge | Target Queue |
|-------------------|-------------------------|--------------|
| `evt-susc-suscripcion-creada` | `VentasAlta` | `suscripciones-{env}-sqs-ventas-alta` |
| `evt-susc-alta-completada` | `VentasAlta` | `suscripciones-{env}-sqs-ventas-alta` |
| `evt-cobranzas-pago-procesado` | `CobranzasResultado` | `suscripciones-{env}-sqs-cobranzas-resultado` |
| `evt-cobranzas-pago-rechazado` | `CobranzasResultado` | `suscripciones-{env}-sqs-cobranzas-resultado` |
| `evt-susc-plan-actualizado` | `FacturacionCambio` | `suscripciones-{env}-sqs-facturacion-cambio` |
| `evt-susc-suscripcion-cancelada` | `FacturacionCambio` | `suscripciones-{env}-sqs-facturacion-cambio` |

### 7.2 Estructura de Evento en EventBridge

```json
{
  "DetailType": "VentasAlta",
  "Source": "suscripciones-api",
  "EventBusName": "suscripciones-{env}-eventbridge-main",
  "Detail": {
    "eventName": "evt-susc-suscripcion-creada",
    "subscriptionId": "sub-123456",
    "customerId": "cust-789",
    "occurredOnUtc": "2026-01-22T10:30:00Z"
  }
}
```

### 7.3 Patrón de Routing en EventBridge

```json
{
  "detail-type": ["VentasAlta", "CobranzasResultado", "FacturacionCambio"]
}
```

**Actualizado:** 22 de Enero, 2026 - Event Pattern basado en `detail-type`
