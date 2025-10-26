class Factura < ApplicationRecord
  self.table_name = 'facturas'
  
  # Configurar la secuencia para Oracle
  self.sequence_name = 'seq_facturas_id'
  
  has_many :item_facturas, dependent: :destroy

  validates :numero, presence: true, uniqueness: true
  validates :cliente_id, presence: true
  validates :fecha_emision, presence: true
  validates :subtotal, presence: true, numericality: { greater_than: 0 }
  validates :impuestos, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total, presence: true, numericality: { greater_than: 0 }
  validates :estado, presence: true, inclusion: { in: %w[borrador emitida cancelada] }

  def self.from_domain(factura_entity)
    new(
      id: factura_entity.id,
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

  def to_domain_entity
    items = item_facturas.map do |item|
      Domain::Entities::ItemFactura.new(
        id: item.id,
        descripcion: item.descripcion,
        cantidad: item.cantidad,
        precio_unitario: item.precio_unitario
      )
    end

    Domain::Entities::Factura.new(
      id: id,
      numero: numero,
      cliente_id: cliente_id,
      fecha_emision: fecha_emision,
      fecha_vencimiento: fecha_vencimiento,
      subtotal: subtotal,
      impuestos: impuestos,
      total: total,
      estado: estado,
      items: items,
      created_at: created_at,
      updated_at: updated_at
    )
  end
end