module Domain
  module Entities
    class Cliente
      attr_reader :id, :nombre, :identificacion, :email, :direccion, :created_at, :updated_at

      def initialize(id:, nombre:, identificacion:, email:, direccion:, created_at: nil, updated_at: nil)
        @id = id
        @nombre = nombre
        @identificacion = identificacion
        @email = email
        @direccion = direccion
        @created_at = created_at
        @updated_at = updated_at
      end

      def valid?
        nombre.present? && identificacion.present? && direccion.present?
      end

      def to_hash
        {
          id: id,
          nombre: nombre,
          identificacion: identificacion,
          email: email,
          direccion: direccion,
          created_at: created_at,
          updated_at: updated_at
        }
      end
    end
  end
end