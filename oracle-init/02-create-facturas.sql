-- Script para crear el usuario y tablas del servicio de facturas
-- Este script se ejecuta automáticamente cuando Oracle se inicia

-- Conectar a la PDB
ALTER SESSION SET CONTAINER = XEPDB1;

-- Crear usuario para el servicio de facturas
CREATE USER facturas_service IDENTIFIED BY facturas123;

-- Otorgar privilegios necesarios
GRANT CONNECT, RESOURCE TO facturas_service;
GRANT CREATE SESSION TO facturas_service;
GRANT CREATE TABLE TO facturas_service;
GRANT CREATE SEQUENCE TO facturas_service;
GRANT CREATE VIEW TO facturas_service;
GRANT CREATE PROCEDURE TO facturas_service;
GRANT CREATE TRIGGER TO facturas_service;

-- Otorgar privilegios adicionales para desarrollo
GRANT UNLIMITED TABLESPACE TO facturas_service;

-- Crear secuencias para IDs
CREATE SEQUENCE facturas_service.seq_facturas_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE facturas_service.seq_items_factura_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Tabla principal de facturas
CREATE TABLE facturas_service.facturas (
    id NUMBER PRIMARY KEY,
    numero VARCHAR2(50) NOT NULL UNIQUE,
    cliente_id NUMBER NOT NULL,
    fecha_emision DATE NOT NULL,
    fecha_vencimiento DATE,
    subtotal NUMBER(15,2) NOT NULL CHECK (subtotal > 0),
    impuestos NUMBER(15,2) NOT NULL CHECK (impuestos >= 0),
    total NUMBER(15,2) NOT NULL CHECK (total > 0),
    estado VARCHAR2(20) NOT NULL DEFAULT 'borrador' CHECK (estado IN ('borrador', 'emitida', 'cancelada')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de items de factura
CREATE TABLE facturas_service.items_factura (
    id NUMBER PRIMARY KEY,
    factura_id NUMBER NOT NULL,
    descripcion VARCHAR2(500) NOT NULL,
    cantidad NUMBER(10,3) NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMBER(15,2) NOT NULL CHECK (precio_unitario > 0),
    subtotal NUMBER(15,2) NOT NULL CHECK (subtotal > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_items_factura_factura FOREIGN KEY (factura_id) REFERENCES facturas_service.facturas(id) ON DELETE CASCADE
);

-- Crear triggers para auto-generar IDs
CREATE OR REPLACE TRIGGER facturas_service.trg_facturas_id
    BEFORE INSERT ON facturas_service.facturas
    FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := facturas_service.seq_facturas_id.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER facturas_service.trg_items_factura_id
    BEFORE INSERT ON facturas_service.items_factura
    FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := facturas_service.seq_items_factura_id.NEXTVAL;
    END IF;
END;
/

-- Índices para mejorar rendimiento
CREATE INDEX idx_facturas_cliente_id ON facturas_service.facturas(cliente_id);
CREATE INDEX idx_facturas_fecha_emision ON facturas_service.facturas(fecha_emision);
CREATE INDEX idx_facturas_estado ON facturas_service.facturas(estado);
CREATE INDEX idx_facturas_numero ON facturas_service.facturas(numero);
CREATE INDEX idx_items_factura_factura_id ON facturas_service.items_factura(factura_id);

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE TRIGGER facturas_service.trg_facturas_updated_at
    BEFORE UPDATE ON facturas_service.facturas
    FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER facturas_service.trg_items_factura_updated_at
    BEFORE UPDATE ON facturas_service.items_factura
    FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Trigger para calcular subtotal automáticamente en items
CREATE OR REPLACE TRIGGER facturas_service.trg_items_factura_subtotal
    BEFORE INSERT OR UPDATE ON facturas_service.items_factura
    FOR EACH ROW
BEGIN
    :NEW.subtotal := :NEW.cantidad * :NEW.precio_unitario;
END;
/

-- Insertar datos de ejemplo (los triggers generarán los IDs automáticamente)
INSERT INTO facturas_service.facturas (numero, cliente_id, fecha_emision, subtotal, impuestos, total, estado) VALUES 
('FAC-20241201-ABC123', 1, DATE '2024-12-01', 1000.00, 190.00, 1190.00, 'emitida');

INSERT INTO facturas_service.items_factura (factura_id, descripcion, cantidad, precio_unitario) VALUES 
(1, 'Producto de ejemplo 1', 2, 500.00);

INSERT INTO facturas_service.facturas (numero, cliente_id, fecha_emision, subtotal, impuestos, total, estado) VALUES 
('FAC-20241201-DEF456', 2, DATE '2024-12-01', 2000.00, 380.00, 2380.00, 'borrador');

INSERT INTO facturas_service.items_factura (factura_id, descripcion, cantidad, precio_unitario) VALUES 
(2, 'Servicio de consultoría', 10, 200.00);

COMMIT;

-- Ajustar las secuencias para que los próximos IDs sean continuos
ALTER SEQUENCE facturas_service.seq_facturas_id RESTART START WITH 3;
ALTER SEQUENCE facturas_service.seq_items_factura_id RESTART START WITH 3;

-- Mostrar información de confirmación
SELECT 'Usuario facturas_service creado exitosamente' AS mensaje FROM DUAL;
SELECT COUNT(*) AS total_facturas FROM facturas_service.facturas;
SELECT COUNT(*) AS total_items FROM facturas_service.items_factura;