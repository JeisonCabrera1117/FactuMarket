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
- **Auditoría Completa**: Logging automático de operaciones (create, read, show, update, delete, error)

### Punto de Entrada Único

Todos los servicios son accesibles a través de una sola URL base:

- `http://localhost:3000/clientes` - Servicio de clientes
- `http://localhost:3000/facturas` - Servicio de facturas
- `http://localhost:3000/audit_logs` - Servicio de auditoría
- `http://localhost:3000/health` - Health check general


## Estructura del Proyecto

```
FactuMarket/
├── backend/
│   ├── clientes-service/                    # Microservicio de clientes (Clean Architecture)
│   │   ├── app/
│   │   │   ├── controllers/
│   │   │   │   └── clientes_controller.rb   # Controlador REST
│   │   │   ├── models/
│   │   │   │   └── cliente.rb               # Modelo de dominio
│   │   │   ├── services/
│   │   │   │   └── audit_logger.rb          # Servicio de logging automático
│   │   │   └── repositories/
│   │   │       └── cliente_repository.rb    # Patrón Repository
│   │   ├── lib/
│   │   │   └── domain/
│   │   │       ├── entities/
│   │   │       │   └── cliente.rb           # Entidad de dominio
│   │   │       └── repositories/
│   │   │           └── cliente_repository_interface.rb  # Interfaz del repositorio
│   │   ├── config/
│   │   │   ├── database.yml                 # Configuración Oracle
│   │   │   └── routes.rb                    # Rutas REST
│   │   └── Dockerfile
│   │
│   ├── facturas-service/                    # Microservicio de facturas (Clean Architecture)
│   │   ├── app/
│   │   │   ├── controllers/
│   │   │   │   └── facturas_controller.rb   # Controlador REST
│   │   │   ├── models/
│   │   │   │   └── factura.rb               # Modelo de dominio
│   │   │   ├── services/
│   │   │   │   └── audit_logger.rb          # Servicio de logging automático
│   │   │   └── repositories/
│   │   │       └── factura_repository.rb    # Patrón Repository
│   │   ├── lib/
│   │   │   └── domain/
│   │   │       ├── entities/
│   │   │       │   └── factura.rb           # Entidad de dominio
│   │   │       └── repositories/
│   │   │           └── factura_repository_interface.rb  # Interfaz del repositorio
│   │   ├── config/
│   │   │   ├── database.yml                 # Configuración Oracle
│   │   │   └── routes.rb                    # Rutas REST
│   │   └── Dockerfile
│   │
│   └── auditoria-service/                   # Microservicio de auditoría (Clean Architecture)
│       ├── app/
│       │   ├── controllers/
│       │   │   ├── audit_logs_controller.rb # Controlador REST para logs
│       │   │   └── health_controller.rb     # Health check con MongoDB
│       │   ├── models/
│       │   │   └── audit_log.rb             # Modelo Mongoid
│       │   ├── services/
│       │   │   └── audit_service.rb         # Servicio de aplicación
│       │   └── repositories/
│       │       └── audit_log_repository_impl.rb  # Implementación del repositorio
│       ├── lib/
│       │   └── domain/
│       │       ├── entities/
│       │       │   └── audit_log.rb         # Entidad de dominio
│       │       └── repositories/
│       │           └── audit_log_repository.rb  # Interfaz del repositorio
│       ├── config/
│       │   ├── mongoid.yml                  # Configuración MongoDB
│       │   ├── database.yml                 # Configuración SQLite (dummy)
│       │   └── routes.rb                    # Rutas REST
│       └── Dockerfile
│
├── oracle-init/                              # Scripts de inicialización de Oracle
│   ├── 01-create-user.sql                   # Creación de usuarios y esquemas
│   └── 02-create-facturas.sql               # Creación de tablas de facturas
├── nginx/                                    # Configuración del API Gateway
│   ├── nginx.conf                           # Configuración del proxy reverso
│   └── Dockerfile
├── docker-compose.yml                       # Orquestación de servicios
├── .env.example                             # Variables de entorno de ejemplo
└── README.md                                # Documentación del proyecto
```

### Arquitectura Clean Architecture por Capas

#### **Capa de Dominio (Domain Layer)**
```
lib/domain/
├── entities/                    # Entidades de negocio
│   ├── cliente.rb              # Reglas de negocio de clientes
│   ├── factura.rb              # Reglas de negocio de facturas
│   └── audit_log.rb            # Reglas de negocio de auditoría
└── repositories/               # Interfaces de repositorios
    ├── cliente_repository_interface.rb
    ├── factura_repository_interface.rb
    └── audit_log_repository.rb
```

#### **Capa de Aplicación (Application Layer)**
```
app/
├── services/                   # Servicios de aplicación
│   ├── audit_logger.rb        # Logging automático
│   └── audit_service.rb       # Lógica de aplicación
├── repositories/               # Implementaciones de repositorios
│   ├── cliente_repository.rb
│   ├── factura_repository.rb
│   └── audit_log_repository_impl.rb
└── models/                     # Modelos de persistencia
    ├── cliente.rb
    ├── factura.rb
    └── audit_log.rb
```

#### **Capa de Infraestructura (Infrastructure Layer)**
```
app/controllers/                # Controladores REST
├── clientes_controller.rb     # API de clientes
├── facturas_controller.rb     # API de facturas
└── audit_logs_controller.rb   # API de auditoría

config/                        # Configuración
├── database.yml               # Configuración Oracle
├── mongoid.yml                # Configuración MongoDB
└── routes.rb                  # Rutas REST
```

### Patrones de Diseño Implementados

#### **Repository Pattern**
- **Interfaz:** `lib/domain/repositories/`
- **Implementación:** `app/repositories/`
- **Beneficio:** Desacoplamiento entre lógica de negocio y persistencia

#### **Service Layer Pattern**
- **Servicios:** `app/services/`
- **Responsabilidad:** Lógica de aplicación y orquestación
- **Ejemplo:** `AuditLogger` para logging automático

#### **MVC Pattern**
- **Modelos:** `app/models/` (persistencia)
- **Vistas:** Respuestas JSON
- **Controladores:** `app/controllers/` (API REST)

#### **Audit Pattern**
- **Logging automático** en todas las operaciones CRUD (create, read, show, update, delete, error)
- **Trazabilidad completa** de cambios
- **Filtros avanzados** para consultas

### Flujo de Datos y Comunicación

#### **Flujo de una Operación CRUD**
```
1. Cliente → API Gateway (Nginx) → Microservicio
2. Controlador → Servicio de Aplicación → Repositorio
3. Repositorio → Base de Datos (Oracle/MongoDB)
4. AuditLogger → Servicio de Auditoría (MongoDB)
5. Respuesta JSON → Cliente
```

#### **Ejemplo de Implementación Clean Architecture**

**Entidad de Dominio (`lib/domain/entities/cliente.rb`):**
```ruby
class Cliente
  attr_reader :id, :nombre, :identificacion, :email, :direccion
  
  def initialize(id:, nombre:, identificacion:, email:, direccion:)
    @id = id
    @nombre = nombre
    @identificacion = identificacion
    @email = email
    @direccion = direccion
  end
  
  def validar_email
    # Reglas de negocio para validación de email
  end
end
```

**Interfaz del Repositorio (`lib/domain/repositories/cliente_repository_interface.rb`):**
```ruby
module ClienteRepositoryInterface
  def find_by_id(id)
    raise NotImplementedError
  end
  
  def save(cliente)
    raise NotImplementedError
  end
  
  def delete(id)
    raise NotImplementedError
  end
end
```

**Implementación del Repositorio (`app/repositories/cliente_repository.rb`):**
```ruby
class ClienteRepository
  include ClienteRepositoryInterface
  
  def find_by_id(id)
    # Implementación con Oracle
  end
  
  def save(cliente)
    # Implementación con Oracle
  end
end
```

**Servicio de Aplicación (`app/services/audit_logger.rb`):**
```ruby
class AuditLogger
  def self.log_operation(service_name, resource_type, action, resource_id, user_id, changes)
    # Envío asíncrono al servicio de auditoría
  end
end
```

### Tecnologías y Herramientas

#### **Bases de Datos**
- **Oracle 21c Express**: Persistencia transaccional para clientes y facturas
- **MongoDB 7.0**: Almacenamiento de logs de auditoría
- **SQLite3**: Configuración dummy para compatibilidad con Rails

#### **Containerización**
- **Docker**: Containerización de microservicios
- **Docker Compose**: Orquestación de servicios
- **Nginx**: API Gateway y proxy reverso

#### **Frameworks y Librerías**
- **Ruby on Rails 7.1**: Framework web para microservicios
- **Mongoid**: ODM para MongoDB
- **Oracle Enhanced Adapter**: Conector para Oracle
- **Puma**: Servidor web de aplicación

#### **Herramientas de Desarrollo**
- **Health Checks**: Monitoreo de servicios
- **Logging Automático**: Trazabilidad completa
- **CORS**: Configuración para desarrollo frontend
- **API REST**: Endpoints estandarizados

## Configuración

### Variables de Entorno

Copia `.env.example` a `.env` y ajusta las variables según tu entorno:

```bash
cp .env.example .env
```

**Nota importante**: El archivo `.env` está excluido del repositorio por seguridad (configurado en `.gitignore`). Solo se sube al repositorio el archivo `.env.example` como plantilla. Asegúrate de crear tu propio archivo `.env` con las credenciales reales en tu entorno local.

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

### Health Checks

- `GET /health` - Health check general del gateway
- `GET /clientes/health` - Health check del servicio de clientes
- `GET /facturas/health` - Health check del servicio de facturas
- `GET /audit_logs/health` - Health check del servicio de auditoría

### Servicio de Clientes

- `GET /clientes` - Listar todos los clientes
- `GET /clientes/:id` - Obtener cliente por ID
- `POST /clientes` - Crear nuevo cliente
- `PUT /clientes/:id` - Actualizar cliente existente
- `DELETE /clientes/:id` - Eliminar cliente

### Servicio de Facturas

- `GET /facturas` - Listar facturas (con filtros opcionales)
- `GET /facturas/:id` - Obtener factura por ID
- `POST /facturas` - Crear nueva factura
- `DELETE /facturas/:id` - Eliminar factura

### Servicio de Auditoría

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

## Sistema de Auditoría

El sistema de auditoría registra automáticamente todas las operaciones realizadas en los microservicios, proporcionando trazabilidad completa y cumplimiento normativo.

### Tipos de Acciones Auditadas

El sistema registra las siguientes acciones en todos los servicios:

- **`create`**: Creación de nuevos recursos (clientes, facturas, etc.)
- **`read`**: Lectura/consulta de listados de recursos
- **`show`**: Consulta de un recurso específico por ID
- **`update`**: Actualización/modificación de recursos existentes
- **`delete`**: Eliminación de recursos
- **`error`**: Registro de errores y excepciones

### Información Registrada en Cada Evento

Cada registro de auditoría incluye la siguiente información:

```json
{
  "service_name": "clientes-service",
  "action": "create",
  "resource_type": "cliente",
  "resource_id": "123",
  "user_id": "usuario@empresa.com",
  "ip_address": "192.168.1.100",
  "user_agent": "Mozilla/5.0...",
  "request_data": {
    "nombre": "Juan Pérez",
    "identificacion": "12345678",
    "email": "juan@example.com"
  },
  "response_data": {
    "id": "123",
    "created_at": "2024-01-01T00:00:00Z"
  },
  "status": "success",
  "error_message": null,
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### Campos de Auditoría

| Campo | Descripción | Ejemplo |
|-------|-------------|---------|
| `service_name` | Nombre del microservicio que genera el evento | `clientes-service` |
| `action` | Tipo de acción realizada | `create`, `read`, `show`, `update`, `delete`, `error` |
| `resource_type` | Tipo de recurso afectado | `cliente`, `factura`, `audit_log` |
| `resource_id` | ID del recurso específico | `123` |
| `user_id` | Identificador del usuario que realiza la acción | `usuario@empresa.com` |
| `ip_address` | Dirección IP desde la que se realizó la solicitud | `192.168.1.100` |
| `user_agent` | Información del navegador/cliente HTTP | `Mozilla/5.0...` |
| `request_data` | Datos enviados en la petición | `{ "nombre": "Juan Pérez" }` |
| `response_data` | Datos retornados en la respuesta | `{ "id": "123" }` |
| `status` | Estado de la operación | `success` o `error` |
| `error_message` | Mensaje de error si la operación falló | `Error de validación` |
| `timestamp` | Fecha y hora del evento | `2024-01-01T00:00:00Z` |

### Filtros Disponibles para Consultas de Auditoría

Puedes filtrar los logs de auditoría usando los siguientes parámetros:

- **Por servicio: `?service_name=clientes-service`**
- **Por tipo de recurso: `?resource_type=cliente`**
- **Por acción: `?action=create`**
- **Por usuario: `?user_id=usuario@empresa.com`**
- **Por rango de fechas: `?start_date=2024-01-01&end_date=2024-01-31`**
- **Por estado: `?errors=true`** (solo errores)
- **Paginación: `?limit=100&offset=0`**

### Ejemplos de Consultas de Auditoría

```bash
# Obtener todos los logs del servicio de clientes
GET /audit_logs?service_name=clientes-service

# Obtener solo operaciones de creación
GET /audit_logs?action=create

# Obtener todos los errores en el último mes
GET /audit_logs?errors=true&start_date=2024-01-01&end_date=2024-01-31

# Obtener el historial completo de un recurso específico
GET /audit_logs?resource_type=cliente&resource_id=123

# Obtener todas las acciones de un usuario
GET /audit_logs?user_id=usuario@empresa.com

# Paginación para grandes volúmenes
GET /audit_logs?limit=50&offset=0
```

### Beneficios del Sistema de Auditoría

- **Trazabilidad Completa**: Registro de todas las operaciones CRUD (create, read, show, update, delete, error) en el sistema
- **Cumplimiento Normativo**: Cumplimiento de requisitos de auditoría y compliance
- **Seguridad**: Identificación de accesos sospechosos o no autorizados
- **Troubleshooting**: Facilita la resolución de problemas y depuración
- **Análisis de Uso**: Entendimiento del uso del sistema por parte de los usuarios
- **Respaldo Legal**: Evidencia de transacciones para soporte legal

## Monitoreo

El sistema incluye health checks para monitorear el estado de los servicios:

- Health check general del gateway
- Health checks específicos de cada microservicio
- Verificación de dependencias entre servicios
- Logging automático de todas las operaciones CRUD (create, read, show, update, delete, error)

