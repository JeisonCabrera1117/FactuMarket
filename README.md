# FactuMarket - Sistema de Microservicios

Sistema de facturación basado en microservicios con Ruby on Rails y Oracle Database.

## Arquitectura

El sistema está compuesto por los siguientes microservicios:

- **api-gateway** (Puerto 3000): Nginx como proxy reverso y punto de entrada único
- **clientes-service** (Puerto interno): Gestión de clientes
- **facturas-service** (Puerto interno): Gestión de facturas
- **oracle-db**: Base de datos Oracle Express

### 🚪 Punto de Entrada Único

Todos los servicios son accesibles a través de una sola URL base:

- `http://localhost:3000/clientes` - Servicio de clientes
- `http://localhost:3000/facturas` - Servicio de facturas
- `http://localhost:3000/health` - Health check general

## Características Implementadas

### ✅ Comunicación entre Microservicios
- El servicio de facturas se comunica con el servicio de clientes via HTTP
- Cliente HTTP robusto con manejo de errores y timeouts configurables
- Comunicación confiable entre microservicios

### ✅ Configuración CORS
- CORS configurado en ambos microservicios para permitir peticiones desde frontend
- Configuración flexible mediante variable de entorno `ALLOWED_ORIGINS`

### ✅ Health Checks
- Health checks básicos de Rails (`/up`)
- Health checks avanzados (`/health`) que verifican dependencias entre servicios
- Monitoreo de conectividad con base de datos y otros microservicios

### ✅ Manejo de Errores Robusto
- Manejo de timeouts, errores de conexión y respuestas HTTP
- Códigos de error específicos para diferentes tipos de fallos
- Respuestas de error claras y descriptivas

## Configuración

### Variables de Entorno

Copia `.env.example` a `.env` y ajusta las variables según tu entorno:

```bash
cp .env.example .env
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

# Probar el API Gateway
./test-api.sh
```

## Endpoints Disponibles

**Base URL:** `http://localhost:3000`

### 🏥 Health Checks

- `GET /health` - Health check general del gateway
- `GET /clientes/health` - Health check del servicio de clientes
- `GET /facturas/health` - Health check del servicio de facturas

### 👥 Servicio de Clientes

- `GET /clientes` - Listar todos los clientes
- `GET /clientes/:id` - Obtener cliente por ID
- `POST /clientes` - Crear nuevo cliente

### 🧾 Servicio de Facturas

- `GET /facturas` - Listar facturas (con filtros opcionales)
- `GET /facturas/:id` - Obtener factura por ID
- `POST /facturas` - Crear nueva factura

### Parámetros de Filtrado para Facturas

- `?fechaInicio=YYYY-MM-DD&fechaFin=YYYY-MM-DD` - Filtrar por rango de fechas
- `?cliente_id=123` - Filtrar por cliente específico

## Estructura de Respuestas

### Respuesta Exitosa
```json
{
  "clientes": [...],
  "cliente": {...},
  "facturas": [...],
  "factura": {...}
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

## Desarrollo

### Estructura del Proyecto

```
FactuMarket/
├── backend/
│   ├── clientes-service/     # Microservicio de clientes
│   └── facturas-service/     # Microservicio de facturas
├── oracle-init/              # Scripts de inicialización de BD
├── docker-compose.yml        # Configuración de servicios
└── .env.example             # Variables de entorno de ejemplo
```

### Agregar un Nuevo Microservicio

1. Crear directorio en `backend/nuevo-servicio/`
2. Configurar Rails API con la misma estructura
3. Agregar servicio al `docker-compose.yml`
4. Configurar variables de entorno
5. Implementar health checks y logging estructurado

## Próximos Pasos

- [ ] Implementar el tercer microservicio
- [ ] Agregar autenticación y autorización
- [ ] Implementar rate limiting
- [ ] Agregar métricas con Prometheus
- [ ] Configurar CI/CD pipeline
- [ ] Implementar tests de integración