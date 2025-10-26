# Servicio de Facturas - FactuMarket

## Descripción

Servicio de microservicios para la creación y gestión de facturas electrónicas, siguiendo la misma estructura que el servicio de clientes.

## Arquitectura

### Estructura del Proyecto

```
app/
├── controllers/          # Controladores REST API
├── models/              # Modelos de Rails
├── services/            # Servicios de negocio
└── repositories/        # Implementaciones de repositorios

lib/
└── domain/              # Entidades de dominio
    ├── entities/        # Entidades de negocio
    └── repositories/    # Interfaces de repositorios
```

## Funcionalidades

### Endpoints REST

- `POST /facturas` - Crear factura
- `GET /facturas/:id` - Consultar factura por ID
- `GET /facturas` - Listar todas las facturas
- `GET /facturas?fechaInicio=xx&fechaFin=yy` - Listar facturas por rango de fechas
- `GET /facturas?cliente_id=xx` - Listar facturas por cliente

### Validaciones

- ✅ Cliente válido (comunicación con servicio de clientes)
- ✅ Monto > 0
- ✅ Fecha de emisión válida
- ✅ Al menos un item en la factura

### Características Técnicas

- **Base de datos**: Oracle con adaptador `oracle_enhanced`
- **Comunicación**: HTTP entre microservicios
- **Arquitectura**: Patrón Repository con entidades de dominio
- **Tests**: RSpec con FactoryBot

## Configuración

### Variables de Entorno

```bash
# Base de datos Oracle
ORACLE_HOST=oracle-db
ORACLE_PORT=1521
ORACLE_SERVICE_NAME=XEPDB1
ORACLE_USERNAME=facturas_service
ORACLE_PASSWORD=facturas123

# Servicios externos
CLIENTES_SERVICE_URL=http://clientes-service:3000
```

### Docker

```bash
# Construir y ejecutar
docker-compose up facturas-service

# Ejecutar tests
docker-compose exec facturas-service bundle exec rspec
```

## Estructura de Base de Datos

### Tabla `facturas`
- `id` - ID único
- `numero` - Número de factura único
- `cliente_id` - ID del cliente (FK al servicio de clientes)
- `fecha_emision` - Fecha de emisión
- `fecha_vencimiento` - Fecha de vencimiento
- `subtotal` - Subtotal sin impuestos
- `impuestos` - Impuestos (IVA 19%)
- `total` - Total de la factura
- `estado` - Estado (borrador, emitida, cancelada)

### Tabla `items_factura`
- `id` - ID único
- `factura_id` - ID de la factura (FK)
- `descripcion` - Descripción del item
- `cantidad` - Cantidad
- `precio_unitario` - Precio unitario
- `subtotal` - Subtotal del item

## Ejemplos de Uso

### Crear Factura

```bash
curl -X POST http://localhost:3002/facturas \
  -H "Content-Type: application/json" \
  -d '{
    "factura": {
      "cliente_id": 1,
      "fecha_emision": "2024-12-01",
      "items": [
        {
          "descripcion": "Producto A",
          "cantidad": 2,
          "precio_unitario": 100.0
        }
      ]
    }
  }'
```

### Consultar Factura

```bash
curl http://localhost:3002/facturas/1
```

### Listar Facturas por Fecha

```bash
curl "http://localhost:3002/facturas?fechaInicio=2024-12-01&fechaFin=2024-12-31"
```

### Listar Facturas por Cliente

```bash
curl "http://localhost:3002/facturas?cliente_id=1"
```

## Comunicación entre Microservicios

El servicio se comunica con el servicio de clientes para:
- Validar que el cliente existe antes de crear una factura
- Obtener información del cliente para el contexto de la factura

## Desarrollo

### Ejecutar Tests

```bash
bundle exec rspec
```

### Ejecutar Migraciones

```bash
bundle exec rails db:prepare
```

### Logs

```bash
docker-compose logs -f facturas-service
```