USE master;
GO
IF DB_ID(N'OsuriDB') IS NOT NULL
BEGIN
    ALTER DATABASE OsuriDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE OsuriDB;
END
GO
CREATE DATABASE OsuriDB COLLATE Modern_Spanish_CI_AS;
GO
USE OsuriDB;
GO

CREATE TABLE dbo.Roles (
    IdRol        INT           IDENTITY(1,1) NOT NULL,
    NombreRol    VARCHAR(50)   NOT NULL,
    Descripcion  VARCHAR(255)  NULL,

    CONSTRAINT PK_Roles PRIMARY KEY (IdRol),
    CONSTRAINT UQ_Roles_NombreRol UNIQUE (NombreRol)
);
GO

CREATE TABLE dbo.Estados_Ruta_Cliente (
    IdEstadoRuta  INT          IDENTITY(1,1) NOT NULL,
    NombreEstado  VARCHAR(50)  NOT NULL,

    CONSTRAINT PK_EstadosRutaCliente PRIMARY KEY (IdEstadoRuta),
    CONSTRAINT UQ_EstadosRutaCliente_NombreEstado UNIQUE (NombreEstado)
);
GO

CREATE TABLE dbo.Tipos_Movimiento (
    IdTipoMovimiento  INT          IDENTITY(1,1) NOT NULL,
    NombreTipo        VARCHAR(50)  NOT NULL,

    CONSTRAINT PK_TiposMovimiento PRIMARY KEY (IdTipoMovimiento),
    CONSTRAINT UQ_TiposMovimiento_NombreTipo UNIQUE (NombreTipo)
);
GO

CREATE TABLE dbo.Estados_Credito (
    IdEstadoCredito  INT          IDENTITY(1,1) NOT NULL,
    NombreEstado     VARCHAR(50)  NOT NULL,

    CONSTRAINT PK_EstadosCredito PRIMARY KEY (IdEstadoCredito),
    CONSTRAINT UQ_EstadosCredito_NombreEstado UNIQUE (NombreEstado)
);
GO

CREATE TABLE dbo.Estados_Mora (
    IdEstadoMora  INT          IDENTITY(1,1) NOT NULL,
    NombreEstado  VARCHAR(50)  NOT NULL,

    CONSTRAINT PK_EstadosMora PRIMARY KEY (IdEstadoMora),
    CONSTRAINT UQ_EstadosMora_NombreEstado UNIQUE (NombreEstado)
);
GO

CREATE TABLE dbo.Estados_Caja (
    IdEstadoCaja  INT          IDENTITY(1,1) NOT NULL,
    NombreEstado  VARCHAR(50)  NOT NULL,

    CONSTRAINT PK_EstadosCaja PRIMARY KEY (IdEstadoCaja),
    CONSTRAINT UQ_EstadosCaja_NombreEstado UNIQUE (NombreEstado)
);
GO

CREATE TABLE dbo.Categorias (
    IdCategoria  INT           IDENTITY(1,1) NOT NULL,
    Nombre       VARCHAR(100)  NOT NULL,
    Descripcion  VARCHAR(255)  NULL,

    CONSTRAINT PK_Categorias PRIMARY KEY (IdCategoria),
    CONSTRAINT UQ_Categorias_Nombre UNIQUE (Nombre)
);
GO

CREATE TABLE dbo.Usuarios (
    IdUsuario      INT           IDENTITY(1,1) NOT NULL,
    Nombre         VARCHAR(100)  NOT NULL,
    Usuario        VARCHAR(50)   NOT NULL,
    Correo         VARCHAR(100)  NOT NULL,
    Password_Hash  VARCHAR(255)  NOT NULL,
    IdRol          INT           NOT NULL,
    Estado         BIT           NOT NULL CONSTRAINT DF_Usuarios_Estado DEFAULT (1),

    CONSTRAINT PK_Usuarios PRIMARY KEY (IdUsuario),
    CONSTRAINT UQ_Usuarios_Usuario UNIQUE (Usuario),
    CONSTRAINT UQ_Usuarios_Correo UNIQUE (Correo),
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (IdRol)
        REFERENCES dbo.Roles (IdRol)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_Usuarios_Usuario
        CHECK (LEN(Usuario) >= 4 AND Usuario NOT LIKE '% %'),
    CONSTRAINT CK_Usuarios_Correo
        CHECK (Correo LIKE '%_@_%._%'),
    CONSTRAINT CK_Usuarios_PasswordHash
        CHECK (LEN(Password_Hash) >= 60)
);
GO

CREATE TABLE dbo.Clientes (
    IdCliente  INT           IDENTITY(1,1) NOT NULL,
    Nombre     VARCHAR(100)  NOT NULL,
    DUI        VARCHAR(20)   NOT NULL,
    Direccion  VARCHAR(255)  NOT NULL,
    Telefono   VARCHAR(20)   NOT NULL,
    Estado     BIT           NOT NULL CONSTRAINT DF_Clientes_Estado DEFAULT (1),

    CONSTRAINT PK_Clientes PRIMARY KEY (IdCliente),
    CONSTRAINT UQ_Clientes_DUI UNIQUE (DUI),
    CONSTRAINT CK_Clientes_DUI
        CHECK (DUI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'),
    CONSTRAINT CK_Clientes_Telefono
        CHECK (Telefono LIKE '[267][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
);
GO

CREATE TABLE dbo.Rutas (
    IdRuta     INT           IDENTITY(1,1) NOT NULL,
    Nombre     VARCHAR(100)  NOT NULL,
    Zona       VARCHAR(100)  NOT NULL,
    Estado     BIT           NOT NULL CONSTRAINT DF_Rutas_Estado DEFAULT (1),
    IdUsuario  INT           NOT NULL,

    CONSTRAINT PK_Rutas PRIMARY KEY (IdRuta),
    CONSTRAINT UQ_Rutas_Nombre UNIQUE (Nombre),
    CONSTRAINT FK_Rutas_Usuarios FOREIGN KEY (IdUsuario)
        REFERENCES dbo.Usuarios (IdUsuario)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

CREATE TABLE dbo.Ruta_Clientes (
    IdRutaCliente  INT  IDENTITY(1,1) NOT NULL,
    IdRuta         INT  NOT NULL,
    IdCliente      INT  NOT NULL,
    OrdenVisita    INT  NOT NULL,
    IdEstadoRuta   INT  NOT NULL CONSTRAINT DF_RutaClientes_IdEstadoRuta DEFAULT (1),

    CONSTRAINT PK_RutaClientes PRIMARY KEY (IdRutaCliente),
    CONSTRAINT UQ_RutaClientes_RutaCliente UNIQUE (IdRuta, IdCliente),
    CONSTRAINT FK_RutaClientes_Rutas FOREIGN KEY (IdRuta)
        REFERENCES dbo.Rutas (IdRuta)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_RutaClientes_Clientes FOREIGN KEY (IdCliente)
        REFERENCES dbo.Clientes (IdCliente)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_RutaClientes_EstadosRutaCliente FOREIGN KEY (IdEstadoRuta)
        REFERENCES dbo.Estados_Ruta_Cliente (IdEstadoRuta)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_RutaClientes_OrdenVisita
        CHECK (OrdenVisita > 0)
);
GO

CREATE TABLE dbo.Productos (
    IdProducto   INT            IDENTITY(1,1) NOT NULL,
    SKU          VARCHAR(50)    NOT NULL,
    Nombre       VARCHAR(100)   NOT NULL,
    Precio       DECIMAL(10,2)  NOT NULL,
    Costo        DECIMAL(10,2)  NOT NULL,
    Estado       BIT            NOT NULL CONSTRAINT DF_Productos_Estado DEFAULT (1),
    IdCategoria  INT            NOT NULL,

    CONSTRAINT PK_Productos PRIMARY KEY (IdProducto),
    CONSTRAINT UQ_Productos_SKU UNIQUE (SKU),
    CONSTRAINT FK_Productos_Categorias FOREIGN KEY (IdCategoria)
        REFERENCES dbo.Categorias (IdCategoria)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_Productos_Precio
        CHECK (Precio > 0),
    CONSTRAINT CK_Productos_Costo
        CHECK (Costo >= 0),
    CONSTRAINT CK_Productos_PrecioCosto
        CHECK (Precio >= Costo)
);
GO

CREATE TABLE dbo.Inventario (
    IdInventario        INT       IDENTITY(1,1) NOT NULL,
    StockActual         INT       NOT NULL CONSTRAINT DF_Inventario_StockActual DEFAULT (0),
    StockMinimo         INT       NOT NULL CONSTRAINT DF_Inventario_StockMinimo DEFAULT (0),
    FechaActualizacion  DATETIME  NOT NULL CONSTRAINT DF_Inventario_FechaActualizacion DEFAULT (GETDATE()),
    IdProducto          INT       NOT NULL,

    CONSTRAINT PK_Inventario PRIMARY KEY (IdInventario),
    CONSTRAINT UQ_Inventario_IdProducto UNIQUE (IdProducto),
    CONSTRAINT FK_Inventario_Productos FOREIGN KEY (IdProducto)
        REFERENCES dbo.Productos (IdProducto)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_Inventario_StockActual
        CHECK (StockActual >= 0),
    CONSTRAINT CK_Inventario_StockMinimo
        CHECK (StockMinimo >= 0)
);
GO

CREATE TABLE dbo.Facturas (
    IdFactura       INT            IDENTITY(1,1) NOT NULL,
    NumeroFactura   VARCHAR(50)    NOT NULL,
    FechaEmision    DATE           NOT NULL,
    MontoTotal      DECIMAL(10,2)  NOT NULL,
    RutaArchivoPDF  VARCHAR(255)   NOT NULL,
    HashDocumento   VARCHAR(64)    NOT NULL,
    FechaCarga      DATETIME       NOT NULL CONSTRAINT DF_Facturas_FechaCarga DEFAULT (GETDATE()),

    CONSTRAINT PK_Facturas PRIMARY KEY (IdFactura),
    CONSTRAINT UQ_Facturas_NumeroFactura UNIQUE (NumeroFactura),
    CONSTRAINT UQ_Facturas_RutaArchivoPDF UNIQUE (RutaArchivoPDF),
    CONSTRAINT UQ_Facturas_HashDocumento UNIQUE (HashDocumento),
    CONSTRAINT CK_Facturas_FechaEmision
        CHECK (FechaEmision <= CAST(GETDATE() AS DATE)),
    CONSTRAINT CK_Facturas_MontoTotal
        CHECK (MontoTotal > 0),
    CONSTRAINT CK_Facturas_ArchivoPDF
        CHECK (RutaArchivoPDF LIKE '%.pdf'),
    CONSTRAINT CK_Facturas_HashSHA256
        CHECK (LEN(HashDocumento) = 64 AND HashDocumento NOT LIKE '%[^0-9a-fA-F]%'),
    CONSTRAINT CK_Facturas_FechaCarga
        CHECK (CAST(FechaCarga AS DATE) >= FechaEmision)
);
GO

CREATE TABLE dbo.Movimientos_Inventario (
    IdMovimientoInv   INT       IDENTITY(1,1) NOT NULL,
    IdTipoMovimiento  INT       NOT NULL,
    Cantidad          INT       NOT NULL,
    Fecha             DATETIME  NOT NULL CONSTRAINT DF_MovInventario_Fecha DEFAULT (GETDATE()),
    IdFactura         INT       NULL,
    IdProducto        INT       NOT NULL,
    IdUsuario         INT       NOT NULL,

    CONSTRAINT PK_MovInventario PRIMARY KEY (IdMovimientoInv),
    CONSTRAINT FK_MovInventario_TiposMovimiento FOREIGN KEY (IdTipoMovimiento)
        REFERENCES dbo.Tipos_Movimiento (IdTipoMovimiento)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_MovInventario_Facturas FOREIGN KEY (IdFactura)
        REFERENCES dbo.Facturas (IdFactura)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_MovInventario_Productos FOREIGN KEY (IdProducto)
        REFERENCES dbo.Productos (IdProducto)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_MovInventario_Usuarios FOREIGN KEY (IdUsuario)
        REFERENCES dbo.Usuarios (IdUsuario)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_MovInventario_Cantidad
        CHECK (Cantidad > 0),
    CONSTRAINT CK_MovInventario_FacturaEntrada
        CHECK (IdTipoMovimiento <> 1 OR IdFactura IS NOT NULL)
);
GO

CREATE TABLE dbo.Creditos (
    IdCredito        INT            IDENTITY(1,1) NOT NULL,
    Cantidad         INT            NOT NULL,
    Modalidad        VARCHAR(20)    NOT NULL,
    MontoOriginal    DECIMAL(10,2)  NOT NULL,
    Cuota            DECIMAL(10,2)  NOT NULL,
    SaldoPendiente   DECIMAL(10,2)  NOT NULL,
    IdEstadoCredito  INT            NOT NULL CONSTRAINT DF_Creditos_IdEstadoCredito DEFAULT (1),
    IdCliente        INT            NOT NULL,
    IdProducto       INT            NOT NULL,
    IdUsuario        INT            NOT NULL,

    CONSTRAINT PK_Creditos PRIMARY KEY (IdCredito),
    CONSTRAINT FK_Creditos_EstadosCredito FOREIGN KEY (IdEstadoCredito)
        REFERENCES dbo.Estados_Credito (IdEstadoCredito)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_Creditos_Clientes FOREIGN KEY (IdCliente)
        REFERENCES dbo.Clientes (IdCliente)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_Creditos_Productos FOREIGN KEY (IdProducto)
        REFERENCES dbo.Productos (IdProducto)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_Creditos_Usuarios FOREIGN KEY (IdUsuario)
        REFERENCES dbo.Usuarios (IdUsuario)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_Creditos_Cantidad
        CHECK (Cantidad > 0),
    CONSTRAINT CK_Creditos_Modalidad
        CHECK (Modalidad IN ('Crédito', 'Contado')),
    CONSTRAINT CK_Creditos_MontoOriginal
        CHECK (MontoOriginal > 0),
    CONSTRAINT CK_Creditos_Saldo
        CHECK (SaldoPendiente >= 0 AND SaldoPendiente <= MontoOriginal),
    CONSTRAINT CK_Creditos_CuotaModalidad
        CHECK ((Modalidad = 'Contado' AND Cuota = 0 AND SaldoPendiente = 0) OR (Modalidad = 'Crédito' AND Cuota > 0 AND Cuota <= MontoOriginal)),
    CONSTRAINT CK_Creditos_CanceladoSinSaldo
        CHECK (IdEstadoCredito <> 5 OR SaldoPendiente = 0)
);
GO

CREATE TABLE dbo.Abonos (
    IdAbono          INT            IDENTITY(1,1) NOT NULL,
    Monto            DECIMAL(10,2)  NOT NULL,
    Fecha            DATETIME       NOT NULL CONSTRAINT DF_Abonos_Fecha DEFAULT (GETDATE()),
    ResultadoVisita  VARCHAR(50)    NOT NULL,
    Observacion      VARCHAR(500)   NULL,
    IdCredito        INT            NOT NULL,
    IdUsuario        INT            NOT NULL,

    CONSTRAINT PK_Abonos PRIMARY KEY (IdAbono),
    CONSTRAINT FK_Abonos_Creditos FOREIGN KEY (IdCredito)
        REFERENCES dbo.Creditos (IdCredito)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_Abonos_Usuarios FOREIGN KEY (IdUsuario)
        REFERENCES dbo.Usuarios (IdUsuario)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_Abonos_ResultadoVisita
        CHECK (ResultadoVisita IN ('Pago realizado', 'No realizó pago')),
    CONSTRAINT CK_Abonos_MontoResultado
        CHECK ((ResultadoVisita = 'Pago realizado' AND Monto > 0) OR (ResultadoVisita = 'No realizó pago' AND Monto = 0))
);
GO

CREATE TABLE dbo.Mora (
    IdMora        INT            IDENTITY(1,1) NOT NULL,
    DiasAtraso    INT            NOT NULL,
    MontoRecargo  DECIMAL(10,2)  NOT NULL CONSTRAINT DF_Mora_MontoRecargo DEFAULT (0),
    IdEstadoMora  INT            NOT NULL CONSTRAINT DF_Mora_IdEstadoMora DEFAULT (1),
    IdCredito     INT            NOT NULL,

    CONSTRAINT PK_Mora PRIMARY KEY (IdMora),
    CONSTRAINT FK_Mora_EstadosMora FOREIGN KEY (IdEstadoMora)
        REFERENCES dbo.Estados_Mora (IdEstadoMora)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_Mora_Creditos FOREIGN KEY (IdCredito)
        REFERENCES dbo.Creditos (IdCredito)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_Mora_DiasAtraso
        CHECK (DiasAtraso > 0),
    CONSTRAINT CK_Mora_MontoRecargo
        CHECK (MontoRecargo >= 0)
);
GO

CREATE TABLE dbo.Movimientos_Caja (
    IdMovimientoCaja  INT            IDENTITY(1,1) NOT NULL,
    Fecha             DATETIME       NOT NULL CONSTRAINT DF_MovCaja_Fecha DEFAULT (GETDATE()),
    TotalRecaudado    DECIMAL(10,2)  NOT NULL,
    EfectivoRecibido  DECIMAL(10,2)  NOT NULL,
    Diferencia        DECIMAL(10,2)  NOT NULL,
    IdEstadoCaja      INT            NOT NULL CONSTRAINT DF_MovCaja_IdEstadoCaja DEFAULT (1),
    IdUsuario         INT            NOT NULL,
    IdRuta            INT            NOT NULL,

    CONSTRAINT PK_MovCaja PRIMARY KEY (IdMovimientoCaja),
    CONSTRAINT FK_MovCaja_EstadosCaja FOREIGN KEY (IdEstadoCaja)
        REFERENCES dbo.Estados_Caja (IdEstadoCaja)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_MovCaja_Usuarios FOREIGN KEY (IdUsuario)
        REFERENCES dbo.Usuarios (IdUsuario)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_MovCaja_Rutas FOREIGN KEY (IdRuta)
        REFERENCES dbo.Rutas (IdRuta)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_MovCaja_TotalRecaudado
        CHECK (TotalRecaudado >= 0),
    CONSTRAINT CK_MovCaja_EfectivoRecibido
        CHECK (EfectivoRecibido >= 0),
    CONSTRAINT CK_MovCaja_Diferencia
        CHECK (Diferencia = EfectivoRecibido - TotalRecaudado)
);
GO

CREATE NONCLUSTERED INDEX IX_Rutas_IdUsuario
    ON dbo.Rutas (IdUsuario);

CREATE NONCLUSTERED INDEX IX_RutaClientes_IdCliente
    ON dbo.Ruta_Clientes (IdCliente);

CREATE NONCLUSTERED INDEX IX_Productos_IdCategoria
    ON dbo.Productos (IdCategoria);

CREATE NONCLUSTERED INDEX IX_MovInventario_Producto_Fecha
    ON dbo.Movimientos_Inventario (IdProducto, Fecha);

CREATE NONCLUSTERED INDEX IX_MovInventario_IdFactura
    ON dbo.Movimientos_Inventario (IdFactura);

CREATE NONCLUSTERED INDEX IX_Creditos_IdCliente
    ON dbo.Creditos (IdCliente);

CREATE NONCLUSTERED INDEX IX_Abonos_IdCredito
    ON dbo.Abonos (IdCredito);

CREATE NONCLUSTERED INDEX IX_Abonos_Usuario_Fecha
    ON dbo.Abonos (IdUsuario, Fecha)
    INCLUDE (Monto);

CREATE NONCLUSTERED INDEX IX_Mora_IdCredito
    ON dbo.Mora (IdCredito);

CREATE NONCLUSTERED INDEX IX_MovCaja_Ruta_Fecha
    ON dbo.Movimientos_Caja (IdRuta, Fecha);
GO
PRINT 'Estructura de OsuriDB creada: 19 tablas, 22 FK, 10 índices.';
GO

USE OsuriDB;
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;

SET IDENTITY_INSERT dbo.Roles ON;
INSERT INTO dbo.Roles (IdRol, NombreRol, Descripcion) VALUES
    (1, 'Administrador', 'Gestiona catálogos, inventario, facturas, créditos y cierres de caja.'),
    (2, 'Cobrador',      'Atiende rutas, coloca productos, registra abonos y entrega el efectivo.');
SET IDENTITY_INSERT dbo.Roles OFF;

SET IDENTITY_INSERT dbo.Estados_Ruta_Cliente ON;
INSERT INTO dbo.Estados_Ruta_Cliente (IdEstadoRuta, NombreEstado) VALUES
    (1, 'Activo'),
    (2, 'Suspendido'),
    (3, 'Retirado');
SET IDENTITY_INSERT dbo.Estados_Ruta_Cliente OFF;

SET IDENTITY_INSERT dbo.Tipos_Movimiento ON;
INSERT INTO dbo.Tipos_Movimiento (IdTipoMovimiento, NombreTipo) VALUES
    (1, 'Entrada'),
    (2, 'Asignación'),
    (3, 'Venta'),
    (4, 'Devolución');
SET IDENTITY_INSERT dbo.Tipos_Movimiento OFF;

SET IDENTITY_INSERT dbo.Estados_Credito ON;
INSERT INTO dbo.Estados_Credito (IdEstadoCredito, NombreEstado) VALUES
    (1, 'Activo'),
    (2, 'En mora'),
    (3, 'Incobrable'),
    (4, 'Anulado'),
    (5, 'Cancelado');
SET IDENTITY_INSERT dbo.Estados_Credito OFF;

SET IDENTITY_INSERT dbo.Estados_Mora ON;
INSERT INTO dbo.Estados_Mora (IdEstadoMora, NombreEstado) VALUES
    (1, 'Pendiente'),
    (2, 'Pagada'),
    (3, 'Condonada');
SET IDENTITY_INSERT dbo.Estados_Mora OFF;

SET IDENTITY_INSERT dbo.Estados_Caja ON;
INSERT INTO dbo.Estados_Caja (IdEstadoCaja, NombreEstado) VALUES
    (1, 'Pendiente'),
    (2, 'Cuadrado'),
    (3, 'Incongruente'),
    (4, 'Justificado');
SET IDENTITY_INSERT dbo.Estados_Caja OFF;

INSERT INTO dbo.Categorias (Nombre, Descripcion) VALUES
    ('Electrodomésticos', 'Licuadoras, televisores, equipos de sonido, planchas y cocinas de mesa.'),
    ('Calzado',           'Zapatos deportivos y de vestir.'),
    ('Prendas de vestir', 'Camisas, pantalones y ropa de temporada.'),
    ('Varios',            'Artículos para el hogar que no entran en otra categoría.');

INSERT INTO dbo.Usuarios (Nombre, Usuario, Correo, Password_Hash, IdRol, Estado) VALUES
    ('Ana Lucía Martínez',       'amartinez',  'amartinez@osuri.com.sv',  '$2b$12$UkZcbeg8u7hSV06OjCUv6bG1f02NekR48YRtFlZlIqbyy1ChVCZDg', 1, 1),
    ('Carlos Ernesto Hernández', 'chernandez', 'chernandez@osuri.com.sv', '$2b$12$OkN69hsQSdkCzpiu5snbQ1lCvAmSKUo9MNRtBrFcQDTgOkrV66m2C', 2, 1),
    ('José Alfredo Ramírez',     'jramirez',   'jramirez@osuri.com.sv',   '$2b$12$L9fxmVgYoLDCEjquO.MyMu0rcUmeHa.t85hTlqdI5hpZAovCVtji0', 2, 1),
    ('Marta Elena Flores',       'mflores',    'mflores@osuri.com.sv',    '$2b$12$E8IvyT/wWs07fP5oOZHuEkA3P1n8hdpBkJdXVLb31wu.iQTBlmuoa', 2, 1),
    ('Luis Antonio Pérez',       'lperez',     'lperez@osuri.com.sv',     '$2b$12$.kVQF65ghBDmXzSKy7W08Ox2KQmKNmB.ScepB6VCj/.xtRAl0dvY3', 2, 0);

INSERT INTO dbo.Clientes (Nombre, DUI, Direccion, Telefono, Estado) VALUES
    ('María José Rivas',        '04512378-8', 'Barrio San Jacinto, calle Francisco Menéndez #105, San Salvador', '7215-4433', 1),
    ('Juan Carlos Mejía',       '03967120-2', 'Mercado Central, puesto 45, San Salvador',                        '2221-0987', 1),
    ('Rosa Amelia Guardado',    '05123964-4', 'Barrio El Calvario, 6a avenida sur #12, San Salvador',            '7788-1203', 1),
    ('Pedro Antonio Aguilar',   '02876541-2', 'Col. Santa Lucía, pasaje 3, casa 14, Ilopango',                   '6104-5521', 1),
    ('Karla Beatriz Orellana',  '06234517-3', 'Col. Las Margaritas, senda 2, casa 9, Soyapango',                 '7342-9910', 1),
    ('Mario Ernesto Alvarado',  '01987654-9', 'Barrio El Centro, 4a avenida norte #22, Soyapango',               '7023-6648', 1),
    ('Sonia Elizabeth Campos',  '04765432-9', 'Col. Zacamil, edificio 12, apartamento 3, Mejicanos',             '6990-2314', 1),
    ('Óscar René Linares',      '03345678-5', 'Mercado de Apopa, local 17, Apopa',                               '7456-8820', 1),
    ('Gloria Estela Ventura',   '05678123-0', 'Res. Altavista, polígono 8, casa 5, Tonacatepeque',               '7611-0457', 1),
    ('Ricardo Alonso Portillo', '02234987-8', 'Cantón Las Delicias, km 14 carretera a Apopa, Apopa',             '2209-7731', 0);

INSERT INTO dbo.Rutas (Nombre, Zona, Estado, IdUsuario) VALUES
    ('Ruta Centro',   'Centro histórico de San Salvador',   1, 2),
    ('Ruta Oriente',  'Soyapango e Ilopango',               1, 3),
    ('Ruta Norte',    'Apopa, Mejicanos y Tonacatepeque',   1, 4),
    ('Ruta Mercados', 'Mercado Central y Mercado de Apopa', 1, 2),
    ('Ruta Sur',      'San Marcos y Santo Tomás',           0, 5);

INSERT INTO dbo.Ruta_Clientes (IdRuta, IdCliente, OrdenVisita, IdEstadoRuta) VALUES
    (1, 1,  1, 1),
    (1, 2,  2, 1),
    (1, 3,  3, 1),
    (2, 4,  1, 1),
    (2, 5,  2, 1),
    (2, 6,  3, 2),
    (3, 7,  1, 1),
    (3, 8,  2, 1),
    (3, 9,  3, 1),
    (3, 10, 4, 3),
    (4, 2,  1, 1),
    (4, 8,  2, 1);

INSERT INTO dbo.Productos (SKU, Nombre, Precio, Costo, Estado, IdCategoria) VALUES
    ('ELE-LIC-001', 'Licuadora de 10 velocidades 1.5 L', 65.00,  38.00,  1, 1),
    ('ELE-TV-032',  'Televisor LED 32 pulgadas Smart',   325.00, 210.00, 1, 1),
    ('ELE-SON-001', 'Equipo de sonido 2.1 Bluetooth',    180.00, 105.00, 1, 1),
    ('ELE-PLA-001', 'Plancha de vapor antiadherente',    35.00,  18.50,  1, 1),
    ('ELE-COC-002', 'Cocina de mesa de 2 quemadores',    55.00,  30.00,  1, 1),
    ('CAL-DEP-040', 'Zapatos deportivos talla 40',       45.00,  22.00,  1, 2),
    ('PRE-CAM-M01', 'Camisa casual manga larga talla M', 18.00,  8.50,   1, 3),
    ('VAR-OLL-005', 'Juego de ollas de 5 piezas',        60.00,  34.00,  1, 4),
    ('ELE-RAD-001', 'Radiograbadora con CD',             40.00,  24.00,  0, 1);

INSERT INTO dbo.Inventario (StockActual, StockMinimo, FechaActualizacion, IdProducto) VALUES
    (19, 5,  '2026-10-07T10:15:00', 1),
    (13, 3,  '2026-11-04T10:30:00', 2),
    (7,  8,  '2026-10-09T09:45:00', 3),
    (24, 5,  '2026-10-17T17:00:00', 4),
    (11, 3,  '2026-10-10T14:20:00', 5),
    (13, 4,  '2026-10-12T10:00:00', 6),
    (28, 10, '2026-10-22T09:10:00', 7),
    (9,  3,  '2026-10-21T15:30:00', 8),
    (5,  0,  '2026-10-20T14:10:00', 9);

INSERT INTO dbo.Facturas (NumeroFactura, FechaEmision, MontoTotal, RutaArchivoPDF, HashDocumento, FechaCarga) VALUES
    ('CCF-0004521', '2026-10-01', 2860.00, '/uploads/facturas/2026/10/CCF-0004521.pdf', '46121e46464dd04f4b08583252ffaaf5695804e1a78d1e0e3be79e91ee100b0a', '2026-10-01T10:15:00'),
    ('CCF-0001187', '2026-10-02', 1302.50, '/uploads/facturas/2026/10/CCF-0001187.pdf', '0a029bef2f8cc36c0cae6a8338effc585d3b8a1349a0199d0722c26bf1041a5d', '2026-10-02T09:00:00'),
    ('CCF-0010342', '2026-10-04', 945.00,  '/uploads/facturas/2026/10/CCF-0010342.pdf', '9315e56010a413d0795ceda3773a8117c78b7bb31055909ce1da60de679a9f7f', '2026-10-05T11:30:00'),
    ('CCF-0004598', '2026-10-20', 460.00,  '/uploads/facturas/2026/10/CCF-0004598.pdf', '62b71ce2bef516fe969e5a502afd7ced9e1293afffada889150ec4b5b8e12e13', '2026-10-20T14:00:00'),
    ('CCF-0004633', '2026-11-02', 1050.00, '/uploads/facturas/2026/11/CCF-0004633.pdf', 'a631ca971059d86b6b3e86265e623e532c6829dad2172090fc47bdfc9970df74', '2026-11-03T08:40:00');

INSERT INTO dbo.Movimientos_Inventario (IdTipoMovimiento, Cantidad, Fecha, IdFactura, IdProducto, IdUsuario) VALUES
    (1, 20, '2026-10-01T10:20:00', 1,    1, 1),
    (1, 10, '2026-10-01T10:20:00', 1,    2, 1),
    (1, 8,  '2026-10-02T09:05:00', 2,    3, 1),
    (1, 25, '2026-10-02T09:05:00', 2,    4, 1),
    (1, 12, '2026-10-05T11:40:00', 3,    5, 1),
    (1, 15, '2026-10-05T11:40:00', 3,    6, 1),
    (1, 30, '2026-10-05T11:40:00', 3,    7, 1),
    (3, 1,  '2026-10-06T09:30:00', NULL, 2, 2),
    (3, 1,  '2026-10-07T10:15:00', NULL, 1, 2),
    (3, 1,  '2026-10-08T11:00:00', NULL, 4, 2),
    (3, 1,  '2026-10-09T09:45:00', NULL, 3, 3),
    (2, 6,  '2026-10-10T08:00:00', NULL, 4, 3),
    (3, 1,  '2026-10-10T14:20:00', NULL, 5, 3),
    (3, 2,  '2026-10-12T10:00:00', NULL, 6, 4),
    (4, 6,  '2026-10-17T17:00:00', NULL, 4, 3),
    (1, 10, '2026-10-20T14:10:00', 4,    8, 1),
    (1, 5,  '2026-10-20T14:10:00', 4,    9, 1),
    (3, 1,  '2026-10-21T15:30:00', NULL, 8, 4),
    (3, 2,  '2026-10-22T09:10:00', NULL, 7, 4),
    (1, 5,  '2026-11-03T08:45:00', 5,    2, 1),
    (3, 1,  '2026-11-04T10:30:00', NULL, 2, 2);

INSERT INTO dbo.Creditos (Cantidad, Modalidad, MontoOriginal, Cuota, SaldoPendiente, IdEstadoCredito, IdCliente, IdProducto, IdUsuario) VALUES
    (1, 'Crédito', 325.00, 5.00, 275.00, 1, 1, 2, 2),
    (1, 'Crédito', 65.00,  2.00, 49.00,  1, 2, 1, 2),
    (1, 'Contado', 35.00,  0.00, 0.00,   5, 3, 4, 2),
    (1, 'Crédito', 180.00, 3.00, 157.00, 2, 4, 3, 3),
    (1, 'Crédito', 55.00,  2.50, 37.50,  1, 5, 5, 3),
    (2, 'Crédito', 90.00,  3.00, 0.00,   5, 7, 6, 4),
    (1, 'Crédito', 60.00,  2.00, 48.00,  2, 8, 8, 4),
    (2, 'Contado', 36.00,  0.00, 0.00,   5, 9, 7, 4),
    (1, 'Crédito', 325.00, 5.00, 275.00, 1, 2, 2, 2);

INSERT INTO dbo.Abonos (Monto, Fecha, ResultadoVisita, Observacion, IdCredito, IdUsuario) VALUES
    (25.00, '2026-10-06T09:35:00', 'Pago realizado',  'Prima al colocar el producto',     1, 2),
    (10.00, '2026-10-07T10:20:00', 'Pago realizado',  'Prima al colocar el producto',     2, 2),
    (20.00, '2026-10-09T09:50:00', 'Pago realizado',  'Prima al colocar el producto',     4, 3),
    (10.00, '2026-10-10T14:25:00', 'Pago realizado',  'Prima al colocar el producto',     5, 3),
    (30.00, '2026-10-12T10:05:00', 'Pago realizado',  'Prima al colocar el producto',     6, 4),
    (5.00,  '2026-10-13T10:10:00', 'Pago realizado',  NULL,                               1, 2),
    (2.00,  '2026-10-13T11:00:00', 'Pago realizado',  NULL,                               2, 2),
    (5.00,  '2026-10-14T10:05:00', 'Pago realizado',  NULL,                               1, 2),
    (0.00,  '2026-10-15T10:20:00', 'No realizó pago', 'Cliente no se encontraba en casa', 1, 2),
    (3.00,  '2026-10-16T09:30:00', 'Pago realizado',  NULL,                               4, 3),
    (2.50,  '2026-10-17T14:00:00', 'Pago realizado',  NULL,                               5, 3),
    (15.00, '2026-10-19T10:30:00', 'Pago realizado',  'Adelantó cinco cuotas',            6, 4),
    (10.00, '2026-10-20T09:50:00', 'Pago realizado',  'Pagó dos cuotas atrasadas',        1, 2),
    (2.00,  '2026-10-20T10:40:00', 'Pago realizado',  NULL,                               2, 2),
    (10.00, '2026-10-21T15:35:00', 'Pago realizado',  'Prima al colocar el producto',     7, 4),
    (0.00,  '2026-10-23T09:40:00', 'No realizó pago', 'Pidió prórroga hasta fin de mes',  4, 3),
    (2.50,  '2026-10-24T13:50:00', 'Pago realizado',  NULL,                               5, 3),
    (15.00, '2026-10-26T10:15:00', 'Pago realizado',  NULL,                               6, 4),
    (0.00,  '2026-10-28T11:10:00', 'No realizó pago', 'Local cerrado por remodelación',   7, 4),
    (0.00,  '2026-10-30T09:35:00', 'No realizó pago', 'Vivienda cerrada',                 4, 3),
    (2.50,  '2026-10-31T14:10:00', 'Pago realizado',  NULL,                               5, 3),
    (30.00, '2026-11-02T10:20:00', 'Pago realizado',  'Canceló el saldo total',           6, 4),
    (5.00,  '2026-11-04T09:40:00', 'Pago realizado',  NULL,                               1, 2),
    (2.00,  '2026-11-04T10:30:00', 'Pago realizado',  NULL,                               2, 2),
    (50.00, '2026-11-04T10:35:00', 'Pago realizado',  'Prima al colocar el producto',     9, 2),
    (2.00,  '2026-11-04T11:00:00', 'Pago realizado',  NULL,                               7, 4);

INSERT INTO dbo.Mora (DiasAtraso, MontoRecargo, IdEstadoMora, IdCredito) VALUES
    (3,  1.50, 2, 1),
    (12, 6.00, 1, 4),
    (8,  3.00, 1, 7),
    (2,  0.00, 3, 5);

INSERT INTO dbo.Movimientos_Caja (Fecha, TotalRecaudado, EfectivoRecibido, Diferencia, IdEstadoCaja, IdUsuario, IdRuta) VALUES
    ('2026-10-06T17:30:00', 25.00, 25.00, 0.00,  2, 2, 1),
    ('2026-10-09T17:40:00', 20.00, 20.00, 0.00,  2, 3, 2),
    ('2026-10-13T17:25:00', 7.00,  7.00,  0.00,  2, 2, 1),
    ('2026-10-19T17:50:00', 15.00, 13.00, -2.00, 4, 4, 3),
    ('2026-10-26T17:45:00', 15.00, 14.00, -1.00, 3, 4, 3),
    ('2026-11-02T17:35:00', 30.00, 30.00, 0.00,  2, 4, 3),
    ('2026-11-04T17:20:00', 57.00, 57.00, 0.00,  2, 2, 1);

COMMIT TRANSACTION;
PRINT 'Datos de prueba insertados: 147 registros en 19 tablas.';
GO

USE OsuriDB;
GO

SELECT 'Roles' AS Tabla, COUNT(*) AS Registros FROM dbo.Roles
UNION ALL SELECT 'Estados_Ruta_Cliente', COUNT(*) FROM dbo.Estados_Ruta_Cliente
UNION ALL SELECT 'Tipos_Movimiento', COUNT(*) FROM dbo.Tipos_Movimiento
UNION ALL SELECT 'Estados_Credito', COUNT(*) FROM dbo.Estados_Credito
UNION ALL SELECT 'Estados_Mora', COUNT(*) FROM dbo.Estados_Mora
UNION ALL SELECT 'Estados_Caja', COUNT(*) FROM dbo.Estados_Caja
UNION ALL SELECT 'Categorias', COUNT(*) FROM dbo.Categorias
UNION ALL SELECT 'Usuarios', COUNT(*) FROM dbo.Usuarios
UNION ALL SELECT 'Clientes', COUNT(*) FROM dbo.Clientes
UNION ALL SELECT 'Rutas', COUNT(*) FROM dbo.Rutas
UNION ALL SELECT 'Ruta_Clientes', COUNT(*) FROM dbo.Ruta_Clientes
UNION ALL SELECT 'Productos', COUNT(*) FROM dbo.Productos
UNION ALL SELECT 'Inventario', COUNT(*) FROM dbo.Inventario
UNION ALL SELECT 'Facturas', COUNT(*) FROM dbo.Facturas
UNION ALL SELECT 'Movimientos_Inventario', COUNT(*) FROM dbo.Movimientos_Inventario
UNION ALL SELECT 'Creditos', COUNT(*) FROM dbo.Creditos
UNION ALL SELECT 'Abonos', COUNT(*) FROM dbo.Abonos
UNION ALL SELECT 'Mora', COUNT(*) FROM dbo.Mora
UNION ALL SELECT 'Movimientos_Caja', COUNT(*) FROM dbo.Movimientos_Caja;

SELECT p.SKU, i.StockActual,
       SUM(CASE WHEN m.IdTipoMovimiento IN (1, 4) THEN m.Cantidad ELSE -m.Cantidad END) AS StockSegunKardex
FROM dbo.Inventario AS i
JOIN dbo.Productos AS p ON p.IdProducto = i.IdProducto
JOIN dbo.Movimientos_Inventario AS m ON m.IdProducto = i.IdProducto
GROUP BY p.SKU, i.StockActual
HAVING i.StockActual <> SUM(CASE WHEN m.IdTipoMovimiento IN (1, 4) THEN m.Cantidad ELSE -m.Cantidad END);

SELECT c.IdCredito, c.MontoOriginal, c.SaldoPendiente, ISNULL(SUM(a.Monto), 0) AS TotalAbonado
FROM dbo.Creditos AS c
LEFT JOIN dbo.Abonos AS a ON a.IdCredito = c.IdCredito
WHERE c.Modalidad = 'Crédito'
GROUP BY c.IdCredito, c.MontoOriginal, c.SaldoPendiente
HAVING c.SaldoPendiente <> c.MontoOriginal - ISNULL(SUM(a.Monto), 0);

SELECT f.NumeroFactura, f.MontoTotal, SUM(m.Cantidad * p.Costo) AS TotalSegunEntradas
FROM dbo.Facturas AS f
JOIN dbo.Movimientos_Inventario AS m ON m.IdFactura = f.IdFactura
JOIN dbo.Productos AS p ON p.IdProducto = m.IdProducto
GROUP BY f.NumeroFactura, f.MontoTotal
HAVING f.MontoTotal <> SUM(m.Cantidad * p.Costo);

SELECT mc.IdMovimientoCaja, mc.TotalRecaudado, ISNULL(SUM(a.Monto), 0) AS TotalSegunAbonos
FROM dbo.Movimientos_Caja AS mc
LEFT JOIN dbo.Abonos AS a
       ON a.IdUsuario = mc.IdUsuario
      AND CAST(a.Fecha AS DATE) = CAST(mc.Fecha AS DATE)
GROUP BY mc.IdMovimientoCaja, mc.TotalRecaudado
HAVING mc.TotalRecaudado <> ISNULL(SUM(a.Monto), 0);

SELECT p.SKU, p.Nombre, i.StockActual, i.StockMinimo
FROM dbo.Inventario AS i
JOIN dbo.Productos AS p ON p.IdProducto = i.IdProducto
WHERE p.Estado = 1 AND i.StockActual <= i.StockMinimo;
GO

USE OsuriDB;
GO

BEGIN TRY
    INSERT INTO dbo.Clientes (Nombre, DUI, Direccion, Telefono)
    VALUES ('Cliente de prueba', '1234567-8', 'Dirección de prueba', '7000-0000');
    PRINT 'P01 NO RECHAZADO: revisar CK_Clientes_DUI';
END TRY
BEGIN CATCH
    PRINT 'P01 OK (error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Clientes (Nombre, DUI, Direccion, Telefono)
    VALUES ('Cliente duplicado', '04512378-8', 'Dirección de prueba', '7000-0000');
    PRINT 'P02 NO RECHAZADO: revisar UQ_Clientes_DUI';
END TRY
BEGIN CATCH
    PRINT 'P02 OK (error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Roles (NombreRol, Descripcion)
    VALUES ('COBRADOR', 'Rol repetido en mayúsculas');
    PRINT 'P03 NO RECHAZADO: revisar UQ_Roles_NombreRol';
END TRY
BEGIN CATCH
    PRINT 'P03 OK (error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Facturas (NumeroFactura, FechaEmision, MontoTotal, RutaArchivoPDF, HashDocumento)
    VALUES ('FAC-PRUEBA-98', '2026-11-06', 100.00, '/uploads/facturas/prueba-98.pdf', 'abc123hash');
    PRINT 'P04 NO RECHAZADO: revisar CK_Facturas_HashSHA256';
END TRY
BEGIN CATCH
    PRINT 'P04 OK (error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Facturas (NumeroFactura, FechaEmision, MontoTotal, RutaArchivoPDF, HashDocumento)
    VALUES ('FAC-PRUEBA-97', '2026-11-06', 100.00, '/uploads/facturas/prueba-97.docx', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'FAC-PRUEBA-97'), 2));
    PRINT 'P05 NO RECHAZADO: revisar CK_Facturas_ArchivoPDF';
END TRY
BEGIN CATCH
    PRINT 'P05 OK (error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Movimientos_Inventario (IdTipoMovimiento, Cantidad, IdFactura, IdProducto, IdUsuario)
    VALUES (1, 5, NULL, 1, 1);
    PRINT 'P06 NO RECHAZADO: revisar CK_MovInventario_FacturaEntrada';
END TRY
BEGIN CATCH
    PRINT 'P06 OK (error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    UPDATE dbo.Inventario SET StockActual = StockActual - 100 WHERE IdProducto = 1;
    PRINT 'P07 NO RECHAZADO: revisar CK_Inventario_StockActual';
END TRY
BEGIN CATCH
    PRINT 'P07 OK (error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    UPDATE dbo.Creditos SET SaldoPendiente = SaldoPendiente - 500.00 WHERE IdCredito = 2;
    PRINT 'P08 NO RECHAZADO: revisar CK_Creditos_Saldo';
END TRY
BEGIN CATCH
    PRINT 'P08 OK (error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Abonos (Monto, ResultadoVisita, IdCredito, IdUsuario)
    VALUES (5.00, 'No realizó pago', 2, 2);
    PRINT 'P09 NO RECHAZADO: revisar CK_Abonos_MontoResultado';
END TRY
BEGIN CATCH
    PRINT 'P09 OK (error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    UPDATE dbo.Productos SET Precio = 10.00 WHERE IdProducto = 1;
    PRINT 'P10 NO RECHAZADO: revisar CK_Productos_PrecioCosto';
END TRY
BEGIN CATCH
    PRINT 'P10 OK (error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    INSERT INTO dbo.Movimientos_Caja (TotalRecaudado, EfectivoRecibido, Diferencia, IdEstadoCaja, IdUsuario, IdRuta)
    VALUES (20.00, 18.00, 2.00, 3, 2, 1);
    PRINT 'P11 NO RECHAZADO: revisar CK_MovCaja_Diferencia';
END TRY
BEGIN CATCH
    PRINT 'P11 OK (error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    DELETE FROM dbo.Estados_Credito WHERE IdEstadoCredito = 5;
    PRINT 'P12 NO RECHAZADO: revisar FK_Creditos_EstadosCredito';
END TRY
BEGIN CATCH
    PRINT 'P12 OK (error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    DELETE FROM dbo.Facturas WHERE IdFactura = 1;
    PRINT 'P13 NO RECHAZADO: revisar FK_MovInventario_Facturas';
END TRY
BEGIN CATCH
    PRINT 'P13 OK (error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;
GO

USE OsuriDB;
GO

CREATE OR ALTER PROCEDURE dbo.SP_RegistrarMovimientoInventario
    @IdTipoMovimiento INT,
    @Cantidad INT,
    @IdFactura INT,
    @IdProducto INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF @Cantidad IS NULL OR @Cantidad <= 0
            THROW 51001, 'La cantidad del movimiento debe ser mayor que cero.', 1;

        IF @IdTipoMovimiento NOT IN (1,2,3,4)
            THROW 51002, 'Tipo de movimiento no válido. Use 1=Entrada, 2=Asignación, 3=Venta o 4=Devolución.', 1;

        IF (@IdTipoMovimiento = 1 AND @IdFactura IS NULL)
            THROW 51003, 'Toda entrada por compra debe estar respaldada por una factura.', 1;
        IF (@IdTipoMovimiento <> 1 AND @IdFactura IS NOT NULL)
            THROW 51004, 'La factura solo se asocia a movimientos de entrada por compra.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE IdUsuario=@IdUsuario AND Estado=1)
            THROW 51005, 'El usuario no existe o está inactivo.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.Facturas WHERE IdFactura=@IdFactura) AND @IdTipoMovimiento=1
            THROW 51006, 'La factura indicada no existe.', 1;

        BEGIN TRANSACTION;

        DECLARE @StockActual INT;
        SELECT @StockActual=StockActual
        FROM dbo.Inventario WITH (UPDLOCK, HOLDLOCK)
        WHERE IdProducto=@IdProducto;

        IF @StockActual IS NULL
            THROW 51007, 'No existe un registro de inventario para el producto indicado.', 1;

        IF @IdTipoMovimiento IN (2,3) AND @StockActual < @Cantidad
            THROW 51008, 'Stock insuficiente para realizar la asignación o venta.', 1;

        INSERT INTO dbo.Movimientos_Inventario
            (IdTipoMovimiento, Cantidad, Fecha, IdFactura, IdProducto, IdUsuario)
        VALUES
            (@IdTipoMovimiento, @Cantidad, GETDATE(), @IdFactura, @IdProducto, @IdUsuario);

        UPDATE dbo.Inventario
        SET StockActual = CASE WHEN @IdTipoMovimiento IN (1,4)
                               THEN StockActual + @Cantidad
                               ELSE StockActual - @Cantidad END,
            FechaActualizacion = GETDATE()
        WHERE IdProducto=@IdProducto;

        COMMIT TRANSACTION;
        SELECT 'Movimiento registrado correctamente.' AS Mensaje,
               @IdTipoMovimiento AS IdTipoMovimiento,
               @StockActual AS StockAnterior,
               CASE WHEN @IdTipoMovimiento IN (1,4) THEN @StockActual+@Cantidad
                    ELSE @StockActual-@Cantidad END AS StockNuevo;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_RegistrarAbono
    @Monto DECIMAL(10,2),
    @ResultadoVisita VARCHAR(50),
    @Observacion VARCHAR(500) = NULL,
    @IdCredito INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        SET @ResultadoVisita = LTRIM(RTRIM(@ResultadoVisita));
        IF @Monto IS NULL OR @Monto < 0
            THROW 51101, 'El monto no puede ser nulo ni negativo.', 1;
        IF @ResultadoVisita IS NULL OR @ResultadoVisita NOT IN ('Pago realizado','No realizó pago')
            THROW 51102, 'El resultado de visita no es válido.', 1;
        IF (@ResultadoVisita='Pago realizado' AND @Monto<=0)
            THROW 51103, 'Un pago realizado debe tener un monto mayor que cero.', 1;
        IF (@ResultadoVisita='No realizó pago' AND @Monto<>0)
            THROW 51104, 'Si no se realizó pago, el monto debe ser cero.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios u JOIN dbo.Roles r ON r.IdRol=u.IdRol
                       WHERE u.IdUsuario=@IdUsuario AND u.Estado=1 AND r.NombreRol='Cobrador')
            THROW 51105, 'El usuario no existe, está inactivo o no tiene el rol Cobrador.', 1;

        BEGIN TRANSACTION;
        DECLARE @Saldo DECIMAL(10,2), @Estado INT;
        SELECT @Saldo=SaldoPendiente, @Estado=IdEstadoCredito
        FROM dbo.Creditos WITH (UPDLOCK, HOLDLOCK)
        WHERE IdCredito=@IdCredito;

        IF @Saldo IS NULL
            THROW 51106, 'El crédito indicado no existe.', 1;
        IF @Estado NOT IN (1,2)
            THROW 51107, 'Solo se pueden registrar abonos en créditos activos o en mora.', 1;
        IF @Monto>@Saldo
            THROW 51108, 'El abono no puede superar el saldo pendiente.', 1;

        INSERT INTO dbo.Abonos
            (Monto, Fecha, ResultadoVisita, Observacion, IdCredito, IdUsuario)
        VALUES
            (@Monto, GETDATE(), @ResultadoVisita, @Observacion, @IdCredito, @IdUsuario);

        IF @ResultadoVisita='Pago realizado'
        BEGIN
            UPDATE dbo.Creditos
            SET SaldoPendiente=SaldoPendiente-@Monto,
                IdEstadoCredito=CASE WHEN SaldoPendiente-@Monto=0 THEN 5 ELSE IdEstadoCredito END
            WHERE IdCredito=@IdCredito;
        END;

        COMMIT TRANSACTION;
        SELECT 'Visita registrada correctamente.' AS Mensaje,
               @IdCredito AS IdCredito,
               CASE WHEN @ResultadoVisita='Pago realizado' THEN @Saldo-@Monto ELSE @Saldo END AS SaldoPendiente;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_LiquidarCajaDiaria
    @EfectivoRecibido DECIMAL(10,2),
    @IdUsuario INT,
    @IdRuta INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF @EfectivoRecibido IS NULL OR @EfectivoRecibido<0
            THROW 51201, 'El efectivo recibido no puede ser nulo ni negativo.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios u JOIN dbo.Roles r ON r.IdRol=u.IdRol
                       WHERE u.IdUsuario=@IdUsuario AND u.Estado=1 AND r.NombreRol='Cobrador')
            THROW 51202, 'El usuario no existe, está inactivo o no tiene el rol Cobrador.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.Rutas WHERE IdRuta=@IdRuta AND IdUsuario=@IdUsuario AND Estado=1)
            THROW 51203, 'La ruta no existe, está inactiva o no está asignada al cobrador indicado.', 1;

        BEGIN TRANSACTION;
        DECLARE @Hoy DATE=CONVERT(DATE,GETDATE());
        DECLARE @Manana DATE=DATEADD(DAY,1,@Hoy);
        DECLARE @TotalRecaudado DECIMAL(10,2);
        DECLARE @Diferencia DECIMAL(10,2);
        DECLARE @IdEstadoCaja INT;
        DECLARE @LockResult INT;

        DECLARE @RecursoBloqueo NVARCHAR(255);
        SET @RecursoBloqueo = CONCAT(
            'Osuri:Caja:', @IdUsuario, ':', @IdRuta, ':',
            CONVERT(CHAR(8), @Hoy, 112)
        );

        EXEC @LockResult = sys.sp_getapplock
            @Resource = @RecursoBloqueo,
            @LockMode = 'Exclusive',
            @LockOwner = 'Transaction',
            @LockTimeout = 10000;
        IF @LockResult < 0
            THROW 51205, 'No fue posible reservar el cierre de caja para esta ruta y fecha.', 1;

        SELECT @TotalRecaudado=ISNULL(SUM(a.Monto),0)
        FROM dbo.Abonos a
        INNER JOIN dbo.Creditos c ON c.IdCredito=a.IdCredito
        INNER JOIN dbo.Ruta_Clientes rc ON rc.IdCliente=c.IdCliente
        WHERE a.IdUsuario=@IdUsuario
          AND a.Fecha>=@Hoy AND a.Fecha<@Manana
          AND rc.IdRuta=@IdRuta
          AND rc.IdEstadoRuta=1;

        IF EXISTS (SELECT 1 FROM dbo.Movimientos_Caja WITH (UPDLOCK,HOLDLOCK)
                   WHERE IdUsuario=@IdUsuario AND IdRuta=@IdRuta
                     AND Fecha>=@Hoy AND Fecha<@Manana)
            THROW 51204, 'Ya existe una liquidación para este cobrador, ruta y día.', 1;

        SET @Diferencia=@EfectivoRecibido-@TotalRecaudado;
        SET @IdEstadoCaja=CASE WHEN @Diferencia=0 THEN 2 ELSE 3 END;

        INSERT INTO dbo.Movimientos_Caja
            (Fecha,TotalRecaudado,EfectivoRecibido,Diferencia,IdEstadoCaja,IdUsuario,IdRuta)
        VALUES
            (GETDATE(),@TotalRecaudado,@EfectivoRecibido,@Diferencia,@IdEstadoCaja,@IdUsuario,@IdRuta);

        COMMIT TRANSACTION;
        SELECT @TotalRecaudado AS TotalRecaudado,
               @EfectivoRecibido AS EfectivoRecibido,
               @Diferencia AS Diferencia,
               @IdEstadoCaja AS IdEstadoCaja,
               'Liquidación registrada correctamente.' AS Mensaje;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_EvitarModificacionFactura
ON dbo.Facturas
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM deleted)
        THROW 51301, 'Las facturas son inmutables: no se permite UPDATE ni DELETE. Registre una nueva factura o un proceso formal de anulación.', 1;
END;
GO

USE OsuriDB;
GO

PRINT 'Prueba 1. SP_RegistrarMovimientoInventario: Entrada de 10 televisores respaldada por la factura 1';
EXEC dbo.SP_RegistrarMovimientoInventario @IdTipoMovimiento = 1, @Cantidad = 10, @IdFactura = 1, @IdProducto = 2, @IdUsuario = 1;
GO

PRINT 'Prueba 2. SP_RegistrarMovimientoInventario: Devolución de 2 televisores (suma existencias, sin factura)';
EXEC dbo.SP_RegistrarMovimientoInventario @IdTipoMovimiento = 4, @Cantidad = 2, @IdFactura = NULL, @IdProducto = 2, @IdUsuario = 1;
GO

PRINT 'Prueba 3. SP_RegistrarMovimientoInventario: Venta de 100 equipos de sonido con solo 7 en existencia';
BEGIN TRY
    EXEC dbo.SP_RegistrarMovimientoInventario @IdTipoMovimiento = 3, @Cantidad = 100, @IdFactura = NULL, @IdProducto = 3, @IdUsuario = 2;
    PRINT 'Resultado inesperado: la operación no fue rechazada.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'Rechazado (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT 'Prueba 4. SP_RegistrarMovimientoInventario: Entrada de mercadería sin factura';
BEGIN TRY
    EXEC dbo.SP_RegistrarMovimientoInventario @IdTipoMovimiento = 1, @Cantidad = 5, @IdFactura = NULL, @IdProducto = 1, @IdUsuario = 1;
    PRINT 'Resultado inesperado: la operación no fue rechazada.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'Rechazado (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT 'Prueba 5. SP_RegistrarAbono: Pago de 15.00 al crédito 1 (saldo 275.00)';
EXEC dbo.SP_RegistrarAbono @Monto = 15.00, @ResultadoVisita = 'Pago realizado', @Observacion = 'Pago recibido', @IdCredito = 1, @IdUsuario = 2;
GO

PRINT 'Prueba 6. SP_RegistrarAbono: Visita sin pago al crédito 2';
EXEC dbo.SP_RegistrarAbono @Monto = 0.00, @ResultadoVisita = 'No realizó pago', @Observacion = 'Cliente ausente', @IdCredito = 2, @IdUsuario = 2;
GO

PRINT 'Prueba 7. SP_RegistrarAbono: Abono de 100.00 a un crédito con saldo de 49.00';
BEGIN TRY
    EXEC dbo.SP_RegistrarAbono @Monto = 100.00, @ResultadoVisita = 'Pago realizado', @Observacion = NULL, @IdCredito = 2, @IdUsuario = 2;
    PRINT 'Resultado inesperado: la operación no fue rechazada.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'Rechazado (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT 'Prueba 8. SP_RegistrarAbono: Abono a un crédito ya cancelado (crédito 3, contado)';
BEGIN TRY
    EXEC dbo.SP_RegistrarAbono @Monto = 5.00, @ResultadoVisita = 'Pago realizado', @Observacion = NULL, @IdCredito = 3, @IdUsuario = 2;
    PRINT 'Resultado inesperado: la operación no fue rechazada.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'Rechazado (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT 'Prueba 9. SP_RegistrarAbono: Abono registrado por el administrador (no es cobrador)';
BEGIN TRY
    EXEC dbo.SP_RegistrarAbono @Monto = 5.00, @ResultadoVisita = 'Pago realizado', @Observacion = NULL, @IdCredito = 1, @IdUsuario = 1;
    PRINT 'Resultado inesperado: la operación no fue rechazada.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'Rechazado (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT 'Prueba 10. SP_LiquidarCajaDiaria: Cierre del cobrador 2 en la ruta 1 entregando 15.00';
EXEC dbo.SP_LiquidarCajaDiaria @EfectivoRecibido = 15.00, @IdUsuario = 2, @IdRuta = 1;
GO

PRINT 'Prueba 11. SP_LiquidarCajaDiaria: Segundo cierre de la misma ruta el mismo día';
BEGIN TRY
    EXEC dbo.SP_LiquidarCajaDiaria @EfectivoRecibido = 15.00, @IdUsuario = 2, @IdRuta = 1;
    PRINT 'Resultado inesperado: la operación no fue rechazada.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'Rechazado (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT 'Prueba 12. SP_LiquidarCajaDiaria: Cierre de una ruta que no pertenece al cobrador';
BEGIN TRY
    EXEC dbo.SP_LiquidarCajaDiaria @EfectivoRecibido = 10.00, @IdUsuario = 2, @IdRuta = 2;
    PRINT 'Resultado inesperado: la operación no fue rechazada.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'Rechazado (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT 'Prueba 13. TR_EvitarModificacionFactura: Modificar el monto de la factura 5';
BEGIN TRY
    UPDATE dbo.Facturas SET MontoTotal = 1.00 WHERE IdFactura = 5;
    PRINT 'Resultado inesperado: la operación no fue rechazada.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'Rechazado (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT 'Prueba 14. TR_EvitarModificacionFactura: Registrar una factura de prueba';
INSERT INTO dbo.Facturas (NumeroFactura, FechaEmision, MontoTotal, RutaArchivoPDF, HashDocumento)
VALUES ('FAC-PRUEBA-01', CONVERT(DATE, GETDATE()), 100.00, '/uploads/facturas/pruebas/FAC-PRUEBA-01.pdf',
        CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'FAC-PRUEBA-01'), 2));
GO

PRINT 'Prueba 15. TR_EvitarModificacionFactura: Eliminar la factura de prueba';
BEGIN TRY
    DELETE FROM dbo.Facturas WHERE NumeroFactura = 'FAC-PRUEBA-01';
    PRINT 'Resultado inesperado: la operación no fue rechazada.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'Rechazado (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '): ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT NumeroFactura, MontoTotal FROM dbo.Facturas WHERE NumeroFactura = 'FAC-PRUEBA-01' OR IdFactura = 5;
GO
