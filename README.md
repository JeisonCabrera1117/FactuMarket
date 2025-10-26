# FactuMarket - Sistema de Facturación Electrónica

Sistema de microservicios para facturación electrónica implementando Clean Architecture, patrón MVC y persistencia en Oracle.

## Arquitectura

### Microservicios Implementados

- **api-gateway** (Puerto 3000): Nginx como proxy reverso y punto de entrada único
- **clientes-service**: Gestión de clientes con Clean Architecture
- **facturas-service**: Gestión de facturas con comunicación entre microservicios
- **auditoria-service**: Servicio de auditoría con MongoDB para logs del sistema
- **oracle-db**: Base de datos Oracle Express para persistencia transaccional
- **mongodb**: Base de datos NoSQL para logs de auditoría

### Principios Aplicados

- **Clean Architecture**: Separación clara entre dominio, aplicación e infraestructura
- **Patrón MVC**: Controladores, modelos y servicios bien estructurados
- **Microservicios**: Servicios independientes con comunicación HTTP
- **Repository Pattern**: Abstracción de la capa de persistencia
- **Auditoría Completa**: Logging de todas las operaciones CRUD

### Punto de Entrada Único

Todos los servicios son accesibles a través de una sola URL base:

- `http://localhost:3000/clientes` - Servicio de clientes
- `http://localhost:3000/facturas` - Servicio de facturas
- `http://localhost:3000/audit_logs` - Servicio de auditoría
- `http://localhost:3000/health` - Health check general

## Configuración

### Variables de Entorno

Copia `.env.example` a `.env` y ajusta las variables según tu entorno:

```bash
cp .env
```

### Ejecución con Docker Compose

```bash
# Construir y ejecutar todos los servicios
docker-compose up --build

# Ejecutar en segundo plano
docker-compose up -d

# Ver logs de un servicio específico
docker-compose logs -f api-gateway
docker-compose logs -f clientes-service
docker-compose logs -f facturas-service
docker-compose logs -f auditoria-service

# Probar el API Gateway
./test-api.sh
```

## Endpoints Disponibles

**Base URL:** `http://localhost:3000`

### 🏥 Health Checks

- `GET /health` - Health check general del gateway
- `GET /clientes/health` - Health check del servicio de clientes
- `GET /facturas/health` - Health check del servicio de facturas
- `GET /audit_logs/health` - Health check del servicio de auditoría

### 👥 Servicio de Clientes

- `GET /clientes` - Listar todos los clientes
- `GET /clientes/:id` - Obtener cliente por ID
- `POST /clientes` - Crear nuevo cliente

### 🧾 Servicio de Facturas

- `GET /facturas` - Listar facturas (con filtros opcionales)
- `GET /facturas/:id` - Obtener factura por ID
- `POST /facturas` - Crear nueva factura

### 📊 Servicio de Auditoría

- `GET /audit_logs` - Listar logs de auditoría (con filtros)
- `GET /audit_logs/:id` - Obtener log específico
- `POST /audit_logs` - Crear log de auditoría
- `DELETE /audit_logs/cleanup` - Limpiar logs antiguos

### Parámetros de Filtrado para Facturas

- `?fechaInicio=YYYY-MM-DD&fechaFin=YYYY-MM-DD` - Filtrar por rango de fechas
- `?cliente_id=123` - Filtrar por cliente específico

### Parámetros de Filtrado para Auditoría

- `?service_name=clientes-service` - Filtrar por servicio
- `?resource_type=cliente` - Filtrar por tipo de recurso
- `?action=create` - Filtrar por acción
- `?user_id=123` - Filtrar por usuario
- `?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD` - Filtrar por rango de fechas
- `?errors=true` - Mostrar solo errores
- `?limit=100&offset=0` - Paginación

## Estructura de Respuestas

### Respuesta Exitosa
```json
{
  "clientes": [...],
  "cliente": {...},
  "facturas": [...],
  "factura": {...},
  "audit_logs": [...],
  "audit_log": {...}
}
```

### Respuesta de Error
```json
{
  "error": "Mensaje de error descriptivo"
}
```

### Health Check Avanzado
```json
{
  "status": "ok|degraded|unhealthy",
  "service": "facturas-service",
  "timestamp": "2024-01-01T00:00:00Z",
  "dependencies": {
    "clientes_service": {
      "status": "healthy",
      "response_time_ms": 45,
      "last_check": "2024-01-01T00:00:00Z"
    },
    "database": {
      "status": "healthy",
      "last_check": "2024-01-01T00:00:00Z"
    }
  }
}
```

## Monitoreo

El sistema incluye health checks para monitorear el estado de los servicios:

- Health check general del gateway
- Health checks específicos de cada microservicio
- Verificación de dependencias entre servicios
- Logging automático de todas las operaciones

## Estructura del Proyecto

```
FactuMarket/
├── backend/
│   ├── clientes-service/     # Microservicio de clientes (Clean Architecture)
│   ├── facturas-service/     # Microservicio de facturas (Clean Architecture)
│   └── auditoria-service/    # Microservicio de auditoría (Clean Architecture)
├── oracle-init/              # Scripts de inicialización de Oracle
├── nginx/                    # Configuración del API Gateway
├── docker-compose.yml        # Orquestación de servicios
└── README.md                 # Documentación del proyecto
```

## Próximos Pasos

- [ ] Agregar pruebas unitarias en capa de dominio
- [ ] Implementar autenticación y autorización
- [ ] Agregar métricas y monitoreo
- [ ] Implementar rate limiting
- [ ] Configurar CI/CD pipeline