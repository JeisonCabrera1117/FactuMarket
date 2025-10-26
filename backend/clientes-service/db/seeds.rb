# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Crear clientes de ejemplo si no existen
clientes_data = [
  { nombre: "Ana García", identificacion: "12345678", email: "ana.garcia@email.com", direccion: "Calle Principal 123" },
  { nombre: "Carlos López", identificacion: "87654321", email: "carlos.lopez@email.com", direccion: "Avenida Central 456" },
  { nombre: "María Rodríguez", identificacion: "11223344", email: "maria.rodriguez@email.com", direccion: "Plaza Mayor 789" }
]

clientes_data.each do |cliente_data|
  Cliente.find_or_create_by!(identificacion: cliente_data[:identificacion]) do |cliente|
    cliente.nombre = cliente_data[:nombre]
    cliente.email = cliente_data[:email]
    cliente.direccion = cliente_data[:direccion]
  end
end

puts "✅ #{Cliente.count} clientes creados/verificados"
