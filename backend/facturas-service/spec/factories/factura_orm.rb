# frozen_string_literal: true

FactoryBot.define do
  factory :factura do
    numero { "FAC-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}" }
    cliente_id { 1 }
    fecha_emision { Date.current }
    fecha_vencimiento { Date.current + 30.days }
    subtotal { 1000.0 }
    impuestos { 190.0 }
    total { 1190.0 }
    estado { 'borrador' }

    after(:create) do |factura|
      create(:item_factura, factura: factura)
    end
  end

  factory :item_factura do
    factura
    descripcion { 'Producto de prueba' }
    cantidad { 2 }
    precio_unitario { 500.0 }
    subtotal { 1000.0 }
  end
end