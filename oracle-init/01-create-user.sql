-- Script para crear el usuario de la aplicación clientes-service
-- Este script se ejecuta automáticamente cuando Oracle se inicia

-- Conectar a la PDB
ALTER SESSION SET CONTAINER = XEPDB1;

-- Crear usuario para el servicio de clientes
CREATE USER clientes_service IDENTIFIED BY clientes123;

-- Otorgar privilegios necesarios
GRANT CONNECT, RESOURCE TO clientes_service;
GRANT CREATE SESSION TO clientes_service;
GRANT CREATE TABLE TO clientes_service;
GRANT CREATE SEQUENCE TO clientes_service;
GRANT CREATE VIEW TO clientes_service;
GRANT CREATE PROCEDURE TO clientes_service;
GRANT CREATE TRIGGER TO clientes_service;

-- Otorgar privilegios adicionales para desarrollo
GRANT UNLIMITED TABLESPACE TO clientes_service;

-- Crear algunas tablas de ejemplo para el servicio de clientes
-- (Esto se puede modificar según las necesidades específicas)

-- Crear secuencia para IDs de clientes
CREATE SEQUENCE clientes_service.seq_clientes_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Tabla de clientes
CREATE TABLE clientes_service.clientes (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    identificacion VARCHAR2(20) NOT NULL UNIQUE,
    email VARCHAR2(100),
    direccion VARCHAR2(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Crear trigger para auto-generar IDs
CREATE OR REPLACE TRIGGER clientes_service.trg_clientes_id
    BEFORE INSERT ON clientes_service.clientes
    FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := clientes_service.seq_clientes_id.NEXTVAL;
    END IF;
END;
/

-- Insertar algunos clientes de ejemplo
INSERT INTO clientes_service.clientes (id, nombre, identificacion, email, direccion) VALUES 
(1, 'Juan Pérez', '12345678', 'juan.perez@email.com', 'Calle Principal 123');
INSERT INTO clientes_service.clientes (id, nombre, identificacion, email, direccion) VALUES 
(2, 'María García', '87654321', 'maria.garcia@email.com', 'Avenida Central 456');
INSERT INTO clientes_service.clientes (id, nombre, identificacion, email, direccion) VALUES 
(3, 'Carlos López', '11223344', 'carlos.lopez@email.com', 'Plaza Mayor 789');

-- Avanzar la secuencia para que el próximo ID sea 4
ALTER SEQUENCE clientes_service.seq_clientes_id RESTART START WITH 4;

COMMIT;

-- Mostrar información de confirmación
SELECT 'Usuario clientes_service creado exitosamente' AS mensaje FROM DUAL;
SELECT COUNT(*) AS total_clientes FROM clientes_service.clientes;