class Cliente < ApplicationRecord
  self.table_name = 'clientes'
  
  # Configurar la secuencia para Oracle
  self.sequence_name = 'seq_clientes_id'
  
  validates :nombre, :direccion, presence: true
  validates :identificacion, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true


  def self.from_domain(cliente_entity)
    new(
      id: cliente_entity.id,
      nombre: cliente_entity.nombre,
      identificacion: cliente_entity.identificacion,
      email: cliente_entity.email,
      direccion: cliente_entity.direccion
    )
  end

  def to_domain_entity
    Domain::Entities::Cliente.new(
      id: id,
      nombre: nombre,
      identificacion: identificacion,
      email: email,
      direccion: direccion
    )
  end
end