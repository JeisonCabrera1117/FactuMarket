require_relative '../../lib/domain/repositories/factura_repository'
require_relative '../models/factura'

class FacturaRepositoryImpl < Domain::Repositories::FacturaRepository
  def find_by_id(id)
    factura = Factura.find_by(id: id)
    return nil unless factura

    factura.to_domain_entity
  end

  def find_by_numero(numero)
    factura = Factura.find_by(numero: numero)
    return nil unless factura

    factura.to_domain_entity
  end

  def find_by_cliente_id(cliente_id)
    Factura.where(cliente_id: cliente_id).map(&:to_domain_entity)
  end

  def find_by_fecha_range(fecha_inicio, fecha_fin)
    Factura.where(fecha_emision: fecha_inicio..fecha_fin).map(&:to_domain_entity)
  end

  def save(factura_entity)
    if factura_entity.id.present? && factura_entity.id != 0 && factura_entity.id != "0.0"
      factura = Factura.find(factura_entity.id)
      factura.update!(
        numero: factura_entity.numero,
        cliente_id: factura_entity.cliente_id,
        fecha_emision: factura_entity.fecha_emision,
        fecha_vencimiento: factura_entity.fecha_vencimiento,
        subtotal: factura_entity.subtotal,
        impuestos: factura_entity.impuestos,
        total: factura_entity.total,
        estado: factura_entity.estado
      )
    else
      factura = Factura.create!(
        numero: factura_entity.numero,
        cliente_id: factura_entity.cliente_id,
        fecha_emision: factura_entity.fecha_emision,
        fecha_vencimiento: factura_entity.fecha_vencimiento,
        subtotal: factura_entity.subtotal,
        impuestos: factura_entity.impuestos,
        total: factura_entity.total,
        estado: factura_entity.estado
      )
    end

    # Guardar items
    factura_entity.items.each do |item_entity|
      ItemFactura.create!(
        factura: factura,
        descripcion: item_entity.descripcion,
        cantidad: item_entity.cantidad,
        precio_unitario: item_entity.precio_unitario
      )
    end

    factura.reload.to_domain_entity
  end

  def all
    Factura.all.map(&:to_domain_entity)
  end

  def delete(id)
    Factura.destroy(id)
  end
end