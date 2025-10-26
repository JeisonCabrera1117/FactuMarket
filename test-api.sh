#!/bin/bash

# Script para probar los endpoints del FactuMarket API Gateway
# Base URL
BASE_URL="http://localhost:3000"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Contadores
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}FactuMarket API Testing${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Función para imprimir resultados
print_result() {
    local status_code=$1
    local description=$2
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ $status_code -ge 200 ] && [ $status_code -lt 300 ]; then
        echo -e "${GREEN}✓${NC} $description - Status: $status_code"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $description - Status: $status_code"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Función para hacer peticiones
make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    if [ -z "$data" ]; then
        curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint"
    else
        curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data"
    fi
}

echo -e "${YELLOW}1. Testing Health Checks${NC}"
echo "----------------------------------------"

# Health check general
response=$(make_request GET /health)
status=$(echo "$response" | tail -n1)
print_result $status "Health check general"

# Health check clientes
response=$(make_request GET /clientes/health)
status=$(echo "$response" | tail -n1)
print_result $status "Health check clientes-service"

# Health check facturas
response=$(make_request GET /facturas/health)
status=$(echo "$response" | tail -n1)
print_result $status "Health check facturas-service"

# Health check auditoría
response=$(make_request GET /audit_logs/health)
status=$(echo "$response" | tail -n1)
print_result $status "Health check auditoria-service"

echo ""

echo -e "${YELLOW}2. Testing Clientes Service${NC}"
echo "----------------------------------------"

# Crear un cliente de prueba con identificacion única
TIMESTAMP=$(date +%s)
RANDOM_NUM=$((RANDOM % 10000))
cliente_data="{
  \"cliente\": {
    \"nombre\": \"Cliente de Prueba $TIMESTAMP\",
    \"identificacion\": \"TEST$TIMESTAMP$RANDOM_NUM\",
    \"email\": \"cliente$TIMESTAMP@prueba.com\",
    \"direccion\": \"Calle Test 123\"
  }
}"

response=$(make_request POST /clientes "$cliente_data")
status=$(echo "$response" | tail -n1)
print_result $status "POST /clientes - Crear cliente"

if [ $status -eq 201 ] || [ $status -eq 200 ]; then
    cliente_id=$(echo "$response" | head -n-1 | jq -r '.cliente.id' | cut -d'.' -f1)
    if [ -n "$cliente_id" ] && [ "$cliente_id" != "0" ]; then
        echo -e "${BLUE}  → Cliente creado con ID: $cliente_id${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  No se pudo crear el cliente${NC}"
    cliente_id=""  # Limpiar variable para evitar errores en tests siguientes
fi

# Listar clientes
response=$(make_request GET /clientes)
status=$(echo "$response" | tail -n1)
print_result $status "GET /clientes - Listar clientes"

# Obtener cliente por ID (si se creó uno)
if [ -n "$cliente_id" ]; then
    response=$(make_request GET /clientes/$cliente_id)
    status=$(echo "$response" | tail -n1)
    print_result $status "GET /clientes/:id - Obtener cliente por ID"
    
    # Actualizar cliente
    updated_cliente_data="{
      \"cliente\": {
        \"nombre\": \"Cliente Actualizado $TIMESTAMP\",
        \"identificacion\": \"TEST$TIMESTAMP$RANDOM_NUM\",
        \"email\": \"cliente_actualizado$TIMESTAMP@prueba.com\",
        \"direccion\": \"Calle Actualizada 456\"
      }
    }"
    
    response=$(make_request PUT /clientes/$cliente_id "$updated_cliente_data")
    status=$(echo "$response" | tail -n1)
    print_result $status "PUT /clientes/:id - Actualizar cliente"
fi

echo ""

echo -e "${YELLOW}3. Testing Facturas Service${NC}"
echo "----------------------------------------"

# Listar facturas
response=$(make_request GET /facturas)
status=$(echo "$response" | tail -n1)
print_result $status "GET /facturas - Listar facturas"

# Crear una factura (solo si tenemos cliente_id)
factura_id=""
if [ -n "$cliente_id" ] && [ "$cliente_id" != "0" ]; then
    FECHA_ACTUAL=$(date +%Y-%m-%d)
    factura_data="{
      \"factura\": {
        \"cliente_id\": ${cliente_id},
        \"fecha_emision\": \"${FECHA_ACTUAL}\",
        \"items\": [
          {
            \"descripcion\": \"Producto de prueba\",
            \"cantidad\": 2,
            \"precio_unitario\": 500.00
          }
        ]
      }
    }"
    
    response=$(make_request POST /facturas "$factura_data")
    status=$(echo "$response" | tail -n1)
    print_result $status "POST /facturas - Crear factura"
    
    if [ $status -eq 201 ] || [ $status -eq 200 ]; then
        factura_id=$(echo "$response" | head -n-1 | jq -r '.factura.id' | cut -d'.' -f1)
        if [ -n "$factura_id" ] && [ "$factura_id" != "0" ]; then
            echo -e "${BLUE}  → Factura creada con ID: $factura_id${NC}"
            
            # Obtener factura por ID
            response=$(make_request GET /facturas/$factura_id)
            status=$(echo "$response" | tail -n1)
            print_result $status "GET /facturas/:id - Obtener factura por ID"
            
            # Probar filtros de facturas
            response=$(make_request GET "/facturas?cliente_id=$cliente_id")
            status=$(echo "$response" | tail -n1)
            print_result $status "GET /facturas?cliente_id=X - Filtrar por cliente"
            
            # Eliminar factura
            response=$(make_request DELETE /facturas/$factura_id)
            status=$(echo "$response" | tail -n1)
            print_result $status "DELETE /facturas/:id - Eliminar factura"
        fi
    fi
fi

# Probar filtro por fecha
FECHA_INICIO=$(date -u -d '7 days ago' +%Y-%m-%d 2>/dev/null || date -u -v-7d +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)
FECHA_FIN=$(date +%Y-%m-%d)
response=$(make_request GET "/facturas?fechaInicio=$FECHA_INICIO&fechaFin=$FECHA_FIN")
status=$(echo "$response" | tail -n1)
print_result $status "GET /facturas?fechaInicio=X&fechaFin=Y - Filtrar por fecha"

echo ""

echo -e "${YELLOW}4. Testing Auditoría Service${NC}"
echo "----------------------------------------"

# Listar logs de auditoría
response=$(make_request GET /audit_logs)
status=$(echo "$response" | tail -n1)
print_result $status "GET /audit_logs - Listar logs de auditoría"

# Listar con filtros por servicio
response=$(make_request GET "/audit_logs?service_name=clientes-service&limit=5")
status=$(echo "$response" | tail -n1)
print_result $status "GET /audit_logs?service_name=X - Filtrar por servicio"

# Listar con filtros por acción
response=$(make_request GET "/audit_logs?action=create&limit=5")
status=$(echo "$response" | tail -n1)
print_result $status "GET /audit_logs?action=X - Filtrar por acción"

# Listar con filtros por recurso
response=$(make_request GET "/audit_logs?resource_type=cliente&limit=5")
status=$(echo "$response" | tail -n1)
print_result $status "GET /audit_logs?resource_type=X - Filtrar por tipo de recurso"

# Listar errores
response=$(make_request GET "/audit_logs?errors=true&limit=5")
status=$(echo "$response" | tail -n1)
print_result $status "GET /audit_logs?errors=true - Filtrar errores"

# Listar con paginación
response=$(make_request GET "/audit_logs?limit=10&offset=0")
status=$(echo "$response" | tail -n1)
print_result $status "GET /audit_logs?limit=X&offset=Y - Paginación"

# Obtener un log específico si hay logs disponibles
response=$(curl -s "$BASE_URL/audit_logs?limit=1")
log_id=$(echo "$response" | jq -r '.audit_logs[0].id' 2>/dev/null)
if [ -n "$log_id" ] && [ "$log_id" != "null" ]; then
    response=$(make_request GET "/audit_logs/$log_id")
    status=$(echo "$response" | tail -n1)
    print_result $status "GET /audit_logs/:id - Obtener log específico"
fi

echo ""

echo -e "${YELLOW}5. Cleanup${NC}"
echo "----------------------------------------"

# Limpiar datos de prueba (eliminar cliente)
if [ -n "$cliente_id" ] && [ "$cliente_id" != "0" ]; then
    response=$(make_request DELETE /clientes/$cliente_id)
    status=$(echo "$response" | tail -n1)
    if [ $status -ge 200 ] && [ $status -lt 300 ]; then
        echo -e "${BLUE}  → Cliente de prueba eliminado${NC}"
    fi
fi

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Summary${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "Total tests: ${TOTAL_TESTS}"
echo -e "${GREEN}Passed: ${PASSED_TESTS}${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Failed: ${FAILED_TESTS}${NC}"
else
    echo -e "Failed: ${FAILED_TESTS}"
fi
echo ""
echo "Endpoints disponibles en: $BASE_URL"
echo "Consulta la documentación en README.md"
