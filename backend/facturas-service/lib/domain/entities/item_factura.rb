module Domain
  module Entities
    class ItemFactura
      attr_reader :id, :descripcion, :cantidad, :precio_unitario, :subtotal

      def initialize(id: nil, descripcion:, cantidad:, precio_unitario:)
        @id = id
        @descripcion = descripcion
        @cantidad = cantidad
        @precio_unitario = precio_unitario
        @subtotal = cantidad * precio_unitario
      end

      def to_hash
        {
          id: id,
          descripcion: descripcion,
          cantidad: cantidad,
          precio_unitario: precio_unitario,
          subtotal: subtotal
        }
      end
    end
  end
end