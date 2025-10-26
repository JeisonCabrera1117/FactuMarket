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
- **Logging automático** en todas las operaciones CRUD
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

### Health Checks

- `GET /health` - Health check general del gateway
- `GET /clientes/health` - Health check del servicio de clientes
- `GET /facturas/health` - Health check del servicio de facturas
- `GET /audit_logs/health` - Health check del servicio de auditoría

### Servicio de Clientes

- `GET /clientes` - Listar todos los clientes
- `GET /clientes/:id` - Obtener cliente por ID
- `POST /clientes` - Crear nuevo cliente

### Servicio de Facturas

- `GET /facturas` - Listar facturas (con filtros opcionales)
- `GET /facturas/:id` - Obtener factura por ID
- `POST /facturas` - Crear nueva factura

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

## Monitoreo

El sistema incluye health checks para monitorear el estado de los servicios:

- Health check general del gateway
- Health checks específicos de cada microservicio
- Verificación de dependencias entre servicios
- Logging automático de todas las operaciones

