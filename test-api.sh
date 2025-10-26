#!/bin/bash

# Script para probar los endpoints del FactuMarket API Gateway
# Base URL
BASE_URL="http://localhost:3000"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}FactuMarket API Testing${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Función para imprimir resultados
print_result() {
    local status_code=$1
    local description=$2
    
    if [ $status_code -ge 200 ] && [ $status_code -lt 300 ]; then
        echo -e "${GREEN}✓${NC} $description - Status: $status_code"
    else
        echo -e "${RED}✗${NC} $description - Status: $status_code"
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
print_result $status "Crear cliente"

if [ $status -eq 201 ] || [ $status -eq 200 ]; then
    cliente_id=$(echo "$response" | head -n-1 | jq -r '.cliente.id' | cut -d'.' -f1)
    if [ -n "$cliente_id" ] && [ "$cliente_id" != "0" ]; then
        echo -e "${BLUE}  ✓ Cliente creado con ID: $cliente_id${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  No se pudo crear el cliente${NC}"
    cliente_id=""  # Limpiar variable para evitar errores en tests siguientes
fi

# Listar clientes
response=$(make_request GET /clientes)
status=$(echo "$response" | tail -n1)
print_result $status "Listar clientes"

# Obtener cliente por ID (si se creó uno)
if [ -n "$cliente_id" ]; then
    response=$(make_request GET /clientes/$cliente_id)
    status=$(echo "$response" | tail -n1)
    print_result $status "Obtener cliente por ID"
fi

echo ""

echo -e "${YELLOW}3. Testing Facturas Service${NC}"
echo "----------------------------------------"

# Listar facturas
response=$(make_request GET /facturas)
status=$(echo "$response" | tail -n1)
print_result $status "Listar facturas"

# Crear una factura (solo si tenemos cliente_id)
if [ -n "$cliente_id" ] && [ "$cliente_id" != "0" ]; then
    FECHA_ACTUAL=$(date +%Y-%m-%d)
    factura_data="{
      \"factura\": {
        \"numero\": \"FAC-TEST-${TIMESTAMP}\",
        \"cliente_id\": ${cliente_id},
        \"fecha_emision\": \"${FECHA_ACTUAL}\",
        \"subtotal\": 1000.00,
        \"impuestos\": 190.00,
        \"total\": 1190.00,
        \"estado\": \"borrador\",
        \"items\": [
          {
            \"descripcion\": \"Producto de prueba\",
            \"cantidad\": 2,
            \"precio_unitario\": 500.00,
            \"subtotal\": 1000.00
          }
        ]
      }
    }"
    
    response=$(make_request POST /facturas "$factura_data")
    status=$(echo "$response" | tail -n1)
    print_result $status "Crear factura"
    factura_id=$(echo "$response" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    
    if [ $status -eq 201 ] || [ $status -eq 200 ]; then
        if [ -n "$factura_id" ] && [ "$factura_id" != "0" ]; then
            echo -e "${BLUE}  ✓ Factura creada con ID: $factura_id${NC}"
        fi
    else
        echo -e "${YELLOW}  ⚠️  No se pudo crear la factura${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  Saltando creación de factura (sin cliente_id)${NC}"
fi

echo ""

echo -e "${YELLOW}4. Testing Auditoría Service${NC}"
echo "----------------------------------------"

# Listar logs de auditoría
response=$(make_request GET /audit_logs)
status=$(echo "$response" | tail -n1)
print_result $status "Listar logs de auditoría"

# Listar con filtros
response=$(make_request GET "/audit_logs?service_name=clientes-service&limit=10")
status=$(echo "$response" | tail -n1)
print_result $status "Listar logs con filtros"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Testing Completed${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Para ver los resultados completos, revisa los logs arriba."
echo "Endpoints disponibles en: $BASE_URL"
