# Feature Specification: Reingeniería del Módulo de Suscripciones

> **Reminder**: Before writing this specification, please review the project's development principles outlined in the [Suscripciones Tech Constitution](/.specify/memory/constitution.md). All functional requirements and designs must align with these core principles.

**Feature Branch**: `001-generate-spec`  
**Created**: 2026-01-12  
**Status**: Draft  
**Input**: User description: "usa la información en el archivo "Docs iniciales/Funcional-spec-dd.md" para generar la especificación"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Gestión Integral del Ciclo de Vida de Suscripciones (Priority: P1)

**Descripción**: Como operador de suscripciones, quiero gestionar el ciclo de vida completo de las suscripciones (altas, bajas, suspensiones, rehabilitaciones, cambios de producto/plan, etc.) de manera centralizada para asegurar la correcta administración de la relación con el suscriptor.

**Por qué esta prioridad**: Es el core del sistema, la funcionalidad principal que permite la operación diaria del módulo de suscripciones.

**Independent Test**: Se puede probar completamente simulando el alta de una suscripción, aplicando diferentes cambios de estado (suspender, rehabilitar, cambiar plan), y finalmente dando de baja la suscripción, verificando que los estados intermedios y finales sean correctos y se generen las novedades esperadas.

**Acceptance Scenarios**:

1.  **Dado** un nuevo cliente, **Cuando** se registra la venta de un plan, **Entonces** se crea una nueva suscripción en estado "activa".
2.  **Dado** una suscripción activa, **Cuando** se detecta una falta de pago, **Entonces** la suscripción cambia a estado "suspendida" automáticamente.
3.  **Dado** una suscripción suspendida, **Cuando** el cliente realiza el pago, **Entonces** la suscripción cambia a estado "activa" automáticamente.
4.  **Dado** una suscripción activa, **Cuando** el cliente solicita una baja, **Entonces** la suscripción cambia a estado "baja" o "cancelada" y se generan las notificaciones correspondientes.
5.  **Dado** una suscripción activa, **Cuando** se solicita un cambio de producto o plan, **Entonces** se registra el cambio y se genera una nueva versión de condiciones comerciales.

---

### User Story 2 - Soporte MultiEmpresa y MultiTenant con Bundles (Priority: P1)

**Descripción**: Como administrador del sistema, quiero que el módulo de suscripciones soporte múltiples unidades de negocio y empresas facturadoras de forma independiente, y que permita agrupar suscripciones en "Bundles" para ofrecer combinaciones de productos bajo un mismo contrato.

**Por qué esta prioridad**: Es un driver clave de la reingeniería, permitiendo la expansión a nuevos modelos de negocio y la gestión de Bonvivir.

**Independent Test**: Se puede probar creando bundles con suscripciones de diferentes unidades de negocio/empresas, y verificando que la facturación y la gestión interna respeten las delimitaciones configuradas.

**Acceptance Scenarios**:

1.  **Dado** un bundle que incluye suscripciones de "La Nación" y "Bonvivir", **Cuando** se procesa la facturación, **Entonces** cada suscripción se notifica a su respectivo sistema de facturación.
2.  **Dado** que el sistema es multi-tenant, **Cuando** una unidad de negocio configura un parámetro específico (ej. días para baja por falta de pago), **Entonces** este parámetro solo aplica a sus suscripciones.
3.  **Dado** un bundle con múltiples suscripciones, **Cuando** cambia la composición del bundle (ej. se añade una suscripción), **Entonces** se registra el cambio y se versionan las condiciones comerciales de todas las suscripciones del bundle.

---

### User Story 3 - Versionado de Condiciones Comerciales (Priority: P2)

**Descripción**: Como analista comercial, quiero que el sistema mantenga un historial versionado de las condiciones comerciales de cada suscripción, de modo que cualquier cambio relevante (producto, plan, bonificación) genere una nueva versión inmutable para auditoría y cálculo retroactivo.

**Por qué esta prioridad**: Es fundamental para la trazabilidad, auditoría y correcta aplicación de descuentos y precios a lo largo del tiempo.

**Independent Test**: Se puede probar realizando una serie de cambios en una suscripción (ej. cambio de plan, aplicación de bonificación), y verificando que cada cambio genere una nueva versión de las condiciones comerciales, y que la versión activa en cada momento sea la correcta.

**Acceptance Scenarios**:

1.  **Dado** una suscripción con condiciones comerciales iniciales, **Cuando** se aplica un descuento por retención, **Entonces** se genera una nueva versión de las condiciones comerciales que incluye el descuento.
2.  **Dado** una suscripción que forma parte de un bundle, **Cuando** la composición del bundle cambia, **Entonces** todas las suscripciones del bundle generan una nueva versión de sus condiciones comerciales.
3.  **Dado** un cambio de plan de venta en una suscripción, **Cuando** se aplica el cambio, **Entonces** se genera una nueva versión de las condiciones comerciales para esa suscripción.

---

### Edge Cases

-   ¿Qué ocurre cuando un `planId` enviado por el sistema de ventas no existe en el catálogo maestro? (Manejo de errores: rechazo de la creación de suscripción).
-   ¿Cómo se manejan los cambios de producto/plan que resultan en un precio inferior al mínimo permitido por la unidad de negocio? (Validación y posible rechazo o notificación).
-   ¿Qué sucede si un evento de cobro exitoso llega para una suscripción que ya ha sido dada de baja? (Ignorar o registrar como un evento de reconciliación).
-   ¿Cómo se asegura la atomicidad en la actualización de estados de suscripciones en un bundle cuando uno de los cambios falla? (Rollback de la transacción o compensación).

## Requirements *(mandatory)*

### Functional Requirements

-   **FR-001**: El sistema DEBE permitir el alta de nuevas suscripciones a partir de la información provista por sistemas externos de venta.
-   **FR-002**: El sistema DEBE gestionar los estados de las suscripciones (Pendiente, activa, cancelada, suspendida, baja, rechazada, terminada) y transicionar entre ellos según eventos internos y externos.
-   **FR-003**: El sistema DEBE permitir la suspensión y rehabilitación de suscripciones.
-   **FR-004**: El sistema DEBE permitir la baja o cancelación de suscripciones.
-   **FR-005**: El sistema DEBE gestionar los cambios de producto y plan de venta asociados a una suscripción.
-   **FR-006**: El sistema DEBE soportar la creación y mantenimiento de Bundles, agrupando múltiples suscripciones.
-   **FR-007**: El sistema DEBE mantener un historial versionado de la composición de cada Bundle.
-   **FR-008**: El sistema DEBE generar una nueva versión de las condiciones comerciales de una suscripción ante cualquier cambio relevante (producto, plan, bonificación).
-   **FR-009**: El sistema DEBE mantener el historial completo de las versiones de condiciones comerciales de cada suscripción para auditoría y cálculos históricos.
-   **FR-010**: El sistema DEBE permitir la gestión de bonificaciones adicionales a las definidas en el plan de venta, incluyendo su aplicación, vigencia y condiciones.
-   **FR-011**: El sistema DEBE procesar novedades (eventos) que afectan el estado o los datos de la suscripción (ej. cambio de domicilio, instrumento de cobro).
-   **FR-012**: El sistema DEBE ser MultiEmpresa y MultiTenant, permitiendo configuraciones específicas por unidad de negocio.
-   **FR-013**: El sistema DEBE notificar a sistemas externos (Facturación, Logística, Gestión de Credenciales) sobre los cambios de estado y novedades de las suscripciones.
-   **FR-014**: Los procesos internos DEBEN ser idempotentes y tolerantes a fallos en la comunicación con sistemas externos.
-   **FR-015**: El sistema DEBE implementar mecanismos de autorización y firma para cambios críticos (ej. modificación de composición de bundle, cambios forzados de versión de condiciones comerciales).
-   **FR-016**: El sistema DEBE implementar el patrón Outbox para garantizar la consistencia transaccional entre los cambios de estado del dominio y la publicación de eventos a sistemas externos, utilizando `LaNacion.Core.Infraestructure.Events.Publisher.MessagePublisher` y procesamiento asíncrono mediante `OutboxProcessor`.

### Key Entities *(include if feature involves data)*

-   **Suscripción**: Representa la relación contractual entre un cliente y un plan de venta/producto. Atributos clave: id, estado, fechaInicio, fechaFin, planDeVentaId.
-   **Bundle**: Agrupación lógica de una o más suscripciones. Atributos clave: id, fechaCreacion, estado, historial de composición.
-   **PlanDeVenta**: Define las condiciones comerciales para la venta de productos. Atributos clave: id, nombre, duracion. (Referenciado, su detalle es "snapshotado" en CondicionComercial).
-   **Producto**: Ítem concreto que se vende o suscribe. Atributos clave: IdMaterialSap, nombre, tipo.
-   **CondicionComercial**: Representa un snapshot inmutable y versionado de las condiciones comerciales aplicadas a una suscripción en un momento dado. Atributos clave: id, version, fechaVigencia, etapas, bonificaciones, descuentos.
-   **Novedad**: Registro de un evento que afecta el estado o los datos de una suscripción. Atributos clave: id, tipo, fecha, datos.
-   **UnidadDeNegocio**: Entidad que agrupa y gestiona suscripciones con configuraciones específicas. Atributos clave: id, nombre.
-   **EmpresaFacturante**: Entidad responsable de la facturación. Atributos clave: cuit, razonSocial.
-   **OutboxMessage**: Entidad que almacena eventos de dominio para publicación asíncrona, garantizando consistencia transaccional. Atributos clave: id, type, data, occurredOnUtc, subject, source, dataSchema, processedOnUtc.

### Dependencias y Suposiciones

Esta sección detalla las interacciones del sistema de Suscripciones con los sistemas externos, basado en el análisis del diagrama de contexto.

#### Entradas al Sistema (Inputs)

El sistema de Suscripciones consume información de los siguientes sistemas:

-   **Ventas**: Provee la información para el alta de nuevas suscripciones y bundles. Es el disparador principal para la creación de entidades en el sistema.
-   **Planes**: Provee la definición de los planes de venta, incluyendo sus condiciones comerciales, duración y productos asociados. Se asume que existe un catálogo maestro de planes.
-   **Productos**: Provee el catálogo de productos que pueden ser parte de una suscripción.
-   **Bajas/Retenciones**: Informa al sistema sobre solicitudes de baja o la aplicación de condiciones especiales de retención que pueden afectar las condiciones comerciales de una suscripción.
-   **Cobranzas**: Notifica el resultado de los procesos de cobro (exitosos o fallidos), lo que dispara cambios de estado en las suscripciones (ej. suspensión o rehabilitación).
-   **Gestion Deuda**: Provee información sobre el estado de deuda de un cliente, que puede ser un factor para la suspensión de suscripciones.

#### Salidas del Sistema (Outputs)

El sistema de Suscripciones notifica cambios de estado y otra información relevante a los siguientes sistemas:

-   **CRM**: Envía información actualizada sobre el estado de las suscripciones y datos del suscriptor para mantener una visión 360 del cliente.
-   **Club-Fidelización**: Notifica cambios en las suscripciones para la correcta asignación o retiro de puntos y beneficios asociados.
-   **SAP**: Informa sobre el ciclo de vida de la suscripción (altas, bajas, cambios) y los detalles necesarios para que SAP genere la facturación correspondiente.
-   **Acceso Digital**: Notifica el estado de las suscripciones para gestionar el acceso de los usuarios a los contenidos digitales.
-   **Circulación**: Informa las altas, bajas y suspensiones de suscripciones a productos físicos para gestionar la logística de distribución.

#### Suposiciones Clave

-   Se asume que cada sistema externo expone una API o un mecanismo de eventos bien definido para la interacción.
-   Se asume que los datos maestros (como el catálogo de Productos y Planes) son consistentes y están disponibles para ser consultados por el sistema de Suscripciones.
-   Se asume que los eventos de los sistemas externos son enviados de manera fiable y que el sistema de Suscripciones cuenta con mecanismos de reintento e idempotencia para procesarlos.

## Success Criteria *(mandatory)*

### Measurable Outcomes

-   **SC-001**: El 99% de las altas de suscripciones disparadas por el sistema de ventas se registran correctamente en el módulo de suscripciones en menos de 5 segundos.
-   **SC-002**: El sistema gestiona el ciclo de vida completo de las suscripciones (alta, suspensión, rehabilitación, baja) sin errores que requieran intervención manual en el 98% de los casos.
-   **SC-003**: El historial de condiciones comerciales de una suscripción DEBE ser siempre consistente y auditable, reflejando todos los cambios relevantes.
-   **SC-004**: Los cambios de estado de las suscripciones se notifican a los sistemas externos (ej. Facturación) en menos de 1 minuto desde que ocurren.
-   **SC-005**: El sistema soporta la operación de 5 unidades de negocio y 2 empresas facturadoras diferentes de forma simultánea, sin degradación en el rendimiento.