class ItemFactura < ApplicationRecord
  self.table_name = 'items_factura'
  belongs_to :factura

  validates :descripcion, presence: true
  validates :cantidad, presence: true, numericality: { greater_than: 0 }
  validates :precio_unitario, presence: true, numericality: { greater_than: 0 }
  validates :subtotal, presence: true, numericality: { greater_than: 0 }

  before_save :calcular_subtotal

  def self.from_domain(item_entity, factura)
    new(
      id: item_entity.id,
      factura: factura,
      descripcion: item_entity.descripcion,
      cantidad: item_entity.cantidad,
      precio_unitario: item_entity.precio_unitario
    )
  end

  def to_domain_entity
    Domain::Entities::ItemFactura.new(
      id: id,
      descripcion: descripcion,
      cantidad: cantidad,
      precio_unitario: precio_unitario
    )
  end

  private

  def calcular_subtotal
    self.subtotal = cantidad * precio_unitario
  end
end