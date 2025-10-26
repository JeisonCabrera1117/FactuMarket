# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Crear facturas de ejemplo si no existen
if Factura.count == 0
  factura1 = Factura.create!(
    numero: "FAC-20241201-TEST001",
    cliente_id: 1,
    fecha_emision: Date.current,
    fecha_vencimiento: Date.current + 30.days,
    subtotal: 1500.00,
    impuestos: 285.00,
    total: 1785.00,
    estado: "emitida"
  )
  
  factura1.item_facturas.create!(
    descripcion: "Producto A",
    cantidad: 3,
    precio_unitario: 500.00,
    subtotal: 1500.00
  )

  factura2 = Factura.create!(
    numero: "FAC-20241201-TEST002",
    cliente_id: 2,
    fecha_emision: Date.current,
    fecha_vencimiento: Date.current + 15.days,
    subtotal: 800.00,
    impuestos: 152.00,
    total: 952.00,
    estado: "borrador"
  )
  
  factura2.item_facturas.create!(
    descripcion: "Servicio B",
    cantidad: 4,
    precio_unitario: 200.00,
    subtotal: 800.00
  )
end

puts "✅ #{Factura.count} facturas creadas/verificadas"
puts "✅ #{ItemFactura.count} items de factura creados/verificados"
