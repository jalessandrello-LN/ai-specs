-- V001__suscripciones_init.sql
-- Reference schema for La Nacion Suscripciones
-- Source of truth for entities/relationships: ai-specs/specs/data-model.md
-- Domain: Subscription management for La Nacion products

-- Table: Cliente
-- Represents a customer who can subscribe to one or more plans
CREATE TABLE IF NOT EXISTS Cliente (
    Id CHAR(36) NOT NULL,
    Nombre VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Telefono VARCHAR(20) NULL,
    TipoDocumento VARCHAR(10) NOT NULL,
    NumeroDocumento VARCHAR(20) NOT NULL,
    FechaNacimiento DATE NULL,
    Provincia VARCHAR(100) NULL,
    Localidad VARCHAR(100) NULL,
    Direccion VARCHAR(500) NULL,
    CodigoPostal VARCHAR(10) NULL,
    Estado VARCHAR(20) NOT NULL DEFAULT 'Activo',
    FechaAlta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FechaUltimaModificacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Origen VARCHAR(50) NULL,
    PRIMARY KEY (Id),
    UNIQUE KEY UX_Cliente_Email (Email),
    UNIQUE KEY UX_Cliente_TipoNumeroDocumento (TipoDocumento, NumeroDocumento),
    KEY IX_Cliente_Estado (Estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: Plan
-- Represents a subscription plan with pricing and terms
CREATE TABLE IF NOT EXISTS Plan (
    Id CHAR(36) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(500) NULL,
    Precio DECIMAL(18, 2) NOT NULL,
    PeriodoFacturacion VARCHAR(20) NOT NULL,
    DiasTrial INT NOT NULL DEFAULT 0,
    PermitePausa BOOLEAN NOT NULL DEFAULT FALSE,
    MaxProductos INT NULL,
    EsPlanDigital BOOLEAN NOT NULL DEFAULT FALSE,
    IncluyeEntregaFisica BOOLEAN NOT NULL DEFAULT FALSE,
    Estado VARCHAR(20) NOT NULL DEFAULT 'Draft',
    FechaAlta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FechaUltimaModificacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Caracteristicas JSON NULL,
    PRIMARY KEY (Id),
    UNIQUE KEY UX_Plan_Nombre (Nombre),
    KEY IX_Plan_Estado (Estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: Suscripcion
-- Represents a customer's subscription to a plan
CREATE TABLE IF NOT EXISTS Suscripcion (
    Id CHAR(36) NOT NULL,
    ClienteId CHAR(36) NOT NULL,
    PlanId CHAR(36) NOT NULL,
    NumeroSuscripcion VARCHAR(50) NOT NULL,
    Estado VARCHAR(20) NOT NULL,
    FechaInicio DATETIME NOT NULL,
    FechaFin DATETIME NULL,
    FechaProximoVencimiento DATETIME NOT NULL,
    FechaCancelacion DATETIME NULL,
    MotivoCancelacion VARCHAR(500) NULL,
    Periodicidad VARCHAR(20) NOT NULL,
    PrecioFinal DECIMAL(18, 2) NOT NULL,
    Notas VARCHAR(1000) NULL,
    FechaAlta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FechaUltimaModificacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Origen VARCHAR(50) NOT NULL,
    CuponDescuentoId CHAR(36) NULL,
    DireccionEntregaId CHAR(36) NULL,
    PRIMARY KEY (Id),
    UNIQUE KEY UX_Suscripcion_NumeroSuscripcion (NumeroSuscripcion),
    KEY IX_Suscripcion_ClienteId (ClienteId),
    KEY IX_Suscripcion_PlanId (PlanId),
    KEY IX_Suscripcion_Estado (Estado),
    KEY IX_Suscripcion_FechaProximoVencimiento (FechaProximoVencimiento),
    CONSTRAINT FK_Suscripcion_Cliente FOREIGN KEY (ClienteId) REFERENCES Cliente(Id),
    CONSTRAINT FK_Suscripcion_Plan FOREIGN KEY (PlanId) REFERENCES Plan(Id),
    CONSTRAINT FK_Suscripcion_CuponDescuento FOREIGN KEY (CuponDescuentoId) REFERENCES CuponDescuento(Id),
    CONSTRAINT FK_Suscripcion_DireccionEntrega FOREIGN KEY (DireccionEntregaId) REFERENCES DireccionEntrega(Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Note: CuponDescuento and DireccionEntrega must be created before Suscripcion due to FK dependencies
-- Adding them before Suscripcion

-- Table: DireccionEntrega
-- Represents delivery addresses for physical products
CREATE TABLE IF NOT EXISTS DireccionEntrega (
    Id CHAR(36) NOT NULL,
    ClienteId CHAR(36) NOT NULL,
    Alias VARCHAR(50) NOT NULL,
    Direccion VARCHAR(500) NOT NULL,
    PisoDepartamento VARCHAR(50) NULL,
    CodigoPostal VARCHAR(10) NOT NULL,
    Provincia VARCHAR(100) NOT NULL,
    Localidad VARCHAR(100) NOT NULL,
    EntreCalles VARCHAR(200) NULL,
    InstruccionesEntrega VARCHAR(500) NULL,
    TelefonoContacto VARCHAR(20) NULL,
    EsDireccionPrincipal BOOLEAN NOT NULL DEFAULT FALSE,
    CoordenadasGps VARCHAR(50) NULL,
    PRIMARY KEY (Id),
    UNIQUE KEY UX_DireccionEntrega_ClienteAlias (ClienteId, Alias),
    KEY IX_DireccionEntrega_ClienteId (ClienteId),
    CONSTRAINT FK_DireccionEntrega_Cliente FOREIGN KEY (ClienteId) REFERENCES Cliente(Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: CuponDescuento
-- Represents discount coupons
CREATE TABLE IF NOT EXISTS CuponDescuento (
    Id CHAR(36) NOT NULL,
    Codigo VARCHAR(50) NOT NULL,
    TipoDescuento VARCHAR(20) NOT NULL,
    ValorDescuento DECIMAL(18, 2) NOT NULL,
    MontoMinimo DECIMAL(18, 2) NULL,
    MontoMaximoDescuento DECIMAL(18, 2) NULL,
    CantidadMaximaUsos INT NULL,
    CantidadUsosActual INT NOT NULL DEFAULT 0,
    FechaInicioValidez DATETIME NOT NULL,
    FechaFinValidez DATETIME NOT NULL,
    EsActivo BOOLEAN NOT NULL DEFAULT TRUE,
    PlanesAplicables JSON NULL,
    Descripcion VARCHAR(500) NULL,
    PRIMARY KEY (Id),
    UNIQUE KEY UX_CuponDescuento_Codigo (Codigo),
    KEY IX_CuponDescuento_EsActivo (EsActivo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: PlanBeneficio
-- Represents features/benefits included in a plan
CREATE TABLE IF NOT EXISTS PlanBeneficio (
    Id CHAR(36) NOT NULL,
    PlanId CHAR(36) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(500) NULL,
    Tipo VARCHAR(50) NOT NULL,
    EsBeneficioBase BOOLEAN NOT NULL DEFAULT FALSE,
    Orden INT NOT NULL DEFAULT 0,
    PRIMARY KEY (Id),
    UNIQUE KEY UX_PlanBeneficio_PlanNombre (PlanId, Nombre),
    KEY IX_PlanBeneficio_PlanId (PlanId),
    CONSTRAINT FK_PlanBeneficio_Plan FOREIGN KEY (PlanId) REFERENCES Plan(Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: Producto
-- Represents a product that can be included in subscriptions
CREATE TABLE IF NOT EXISTS Producto (
    Id CHAR(36) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(500) NULL,
    Tipo VARCHAR(50) NOT NULL,
    PrecioSugerido DECIMAL(18, 2) NULL,
    EsActivo BOOLEAN NOT NULL DEFAULT TRUE,
    FechaAlta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Id),
    UNIQUE KEY UX_Producto_Nombre (Nombre),
    KEY IX_Producto_Tipo (Tipo),
    KEY IX_Producto_EsActivo (EsActivo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: SuscripcionProducto
-- Represents products associated with a subscription
CREATE TABLE IF NOT EXISTS SuscripcionProducto (
    Id CHAR(36) NOT NULL,
    SuscripcionId CHAR(36) NOT NULL,
    ProductoId CHAR(36) NOT NULL,
    Cantidad INT NOT NULL DEFAULT 1,
    PrecioUnitario DECIMAL(18, 2) NOT NULL,
    FechaAgregado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Id),
    KEY IX_SuscripcionProducto_SuscripcionId (SuscripcionId),
    KEY IX_SuscripcionProducto_ProductoId (ProductoId),
    CONSTRAINT FK_SuscripcionProducto_Suscripcion FOREIGN KEY (SuscripcionId) REFERENCES Suscripcion(Id),
    CONSTRAINT FK_SuscripcionProducto_Producto FOREIGN KEY (ProductoId) REFERENCES Producto(Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: MetodoPago
-- Represents payment methods for a customer
CREATE TABLE IF NOT EXISTS MetodoPago (
    Id CHAR(36) NOT NULL,
    ClienteId CHAR(36) NOT NULL,
    Tipo VARCHAR(30) NOT NULL,
    Identificador VARCHAR(500) NOT NULL,
    UltimosDigitos VARCHAR(4) NOT NULL,
    Titular VARCHAR(100) NOT NULL,
    FechaVencimiento DATE NULL,
    Marca VARCHAR(50) NULL,
    EsMetodoPrincipal BOOLEAN NOT NULL DEFAULT FALSE,
    FechaAlta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Id),
    KEY IX_MetodoPago_ClienteId (ClienteId),
    CONSTRAINT FK_MetodoPago_Cliente FOREIGN KEY (ClienteId) REFERENCES Cliente(Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: Factura
-- Represents an invoice for a subscription
CREATE TABLE IF NOT EXISTS Factura (
    Id CHAR(36) NOT NULL,
    SuscripcionId CHAR(36) NOT NULL,
    NumeroFactura VARCHAR(50) NOT NULL,
    FechaEmision DATETIME NOT NULL,
    FechaVencimiento DATETIME NOT NULL,
    PeriodoDesde DATETIME NOT NULL,
    PeriodoHasta DATETIME NOT NULL,
    Subtotal DECIMAL(18, 2) NOT NULL,
    Impuestos DECIMAL(18, 2) NOT NULL,
    Descuentos DECIMAL(18, 2) NOT NULL,
    Total DECIMAL(18, 2) NOT NULL,
    Estado VARCHAR(20) NOT NULL,
    FechaPago DATETIME NULL,
    MetodoPagoId CHAR(36) NULL,
    CodigoAutorizacion VARCHAR(100) NULL,
    Observaciones VARCHAR(1000) NULL,
    PRIMARY KEY (Id),
    UNIQUE KEY UX_Factura_NumeroFactura (NumeroFactura),
    KEY IX_Factura_SuscripcionId (SuscripcionId),
    KEY IX_Factura_Estado (Estado),
    KEY IX_Factura_FechaVencimiento (FechaVencimiento),
    CONSTRAINT FK_Factura_Suscripcion FOREIGN KEY (SuscripcionId) REFERENCES Suscripcion(Id),
    CONSTRAINT FK_Factura_MetodoPago FOREIGN KEY (MetodoPagoId) REFERENCES MetodoPago(Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: FacturaDetalle
-- Represents line items on an invoice
CREATE TABLE IF NOT EXISTS FacturaDetalle (
    Id CHAR(36) NOT NULL,
    FacturaId CHAR(36) NOT NULL,
    Descripcion VARCHAR(500) NOT NULL,
    Cantidad INT NOT NULL DEFAULT 1,
    PrecioUnitario DECIMAL(18, 2) NOT NULL,
    Importe DECIMAL(18, 2) NOT NULL,
    TipoItem VARCHAR(30) NOT NULL,
    PRIMARY KEY (Id),
    KEY IX_FacturaDetalle_FacturaId (FacturaId),
    CONSTRAINT FK_FacturaDetalle_Factura FOREIGN KEY (FacturaId) REFERENCES Factura(Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: Pago
-- Represents a payment transaction
CREATE TABLE IF NOT EXISTS Pago (
    Id CHAR(36) NOT NULL,
    SuscripcionId CHAR(36) NOT NULL,
    FacturaId CHAR(36) NOT NULL,
    MetodoPagoId CHAR(36) NOT NULL,
    Monto DECIMAL(18, 2) NOT NULL,
    FechaPago DATETIME NOT NULL,
    Estado VARCHAR(20) NOT NULL,
    CodigoTransaccion VARCHAR(100) NOT NULL,
    CodigoAutorizacion VARCHAR(100) NULL,
    ReferenciaPago VARCHAR(200) NULL,
    Notas VARCHAR(1000) NULL,
    IpOrigen VARCHAR(50) NULL,
    PRIMARY KEY (Id),
    KEY IX_Pago_SuscripcionId (SuscripcionId),
    KEY IX_Pago_FacturaId (FacturaId),
    KEY IX_Pago_CodigoTransaccion (CodigoTransaccion),
    KEY IX_Pago_Estado (Estado),
    CONSTRAINT FK_Pago_Suscripcion FOREIGN KEY (SuscripcionId) REFERENCES Suscripcion(Id),
    CONSTRAINT FK_Pago_Factura FOREIGN KEY (FacturaId) REFERENCES Factura(Id),
    CONSTRAINT FK_Pago_MetodoPago FOREIGN KEY (MetodoPagoId) REFERENCES MetodoPago(Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: OutboxEvent
-- Stores events to be published (Outbox Pattern for transactional messaging)
CREATE TABLE IF NOT EXISTS OutboxEvent (
    Id CHAR(36) NOT NULL,
    EventType VARCHAR(100) NOT NULL,
    EventName VARCHAR(200) NOT NULL,
    Payload JSON NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ProcessedAt DATETIME NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    RetryCount INT NOT NULL DEFAULT 0,
    LastError TEXT NULL,
    PRIMARY KEY (Id),
    KEY IX_OutboxEvent_Status_CreatedAt (Status, CreatedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add foreign key constraints for Suscripcion now that all referenced tables exist
-- Note: The FK constraints were already added in the Suscripcion table definition above
-- This is just a reminder that the table dependencies must be respected

-- Table: MensajesRecibidos (for SQS Listener idempotency)
-- Stores processed message IDs to ensure idempotent message processing
CREATE TABLE IF NOT EXISTS MensajesRecibidos (
    Id CHAR(36) NOT NULL,
    MessageId VARCHAR(100) NOT NULL,
    ReceiptHandle VARCHAR(500) NOT NULL,
    EventName VARCHAR(200) NOT NULL,
    ProcessedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Id),
    UNIQUE KEY UX_MensajesRecibidos_MessageId_EventName (MessageId, EventName),
    KEY IX_MensajesRecibidos_ProcessedAt (ProcessedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
