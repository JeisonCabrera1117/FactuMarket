require_relative '../../lib/domain/repositories/cliente_repository'
require_relative '../models/cliente'

class ClienteRepositoryImpl < Domain::Repositories::ClienteRepository
  def find_by_id(id)
    cliente = Cliente.find_by(id: id)
    return nil unless cliente

    cliente.to_domain_entity
  end

  def find_by_identificacion(identificacion)
    cliente = Cliente.find_by(identificacion: identificacion)
    return nil unless cliente

    cliente.to_domain_entity
  end

  def find_by_identificacion?(identificacion)
    Cliente.exists?(identificacion: identificacion)
  end

  def save(cliente_entity)
    if cliente_entity.id.present?
      cliente = Cliente.find(cliente_entity.id)
      cliente.update!(
        nombre: cliente_entity.nombre,
        identificacion: cliente_entity.identificacion,
        email: cliente_entity.email,
        direccion: cliente_entity.direccion
      )
    else
      cliente = Cliente.create!(
        nombre: cliente_entity.nombre,
        identificacion: cliente_entity.identificacion,
        email: cliente_entity.email,
        direccion: cliente_entity.direccion
      )
    end
    cliente.to_domain_entity
  end

  def all
    Cliente.all.map(&:to_domain_entity)
  end

  def delete(id)
    Cliente.destroy(id)
  end
end