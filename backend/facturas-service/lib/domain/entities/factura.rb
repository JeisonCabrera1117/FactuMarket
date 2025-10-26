module Domain
  module Entities
    class Factura
      attr_reader :id, :numero, :cliente_id, :fecha_emision, :fecha_vencimiento, 
                  :subtotal, :impuestos, :total, :estado, :items, :created_at, :updated_at

      def initialize(id:, numero:, cliente_id:, fecha_emision:, fecha_vencimiento: nil,
                     subtotal: 0.0, impuestos: 0.0, total: 0.0, estado: 'borrador',
                     items: [], created_at: nil, updated_at: nil)
        @id = id
        @numero = numero
        @cliente_id = cliente_id
        @fecha_emision = fecha_emision
        @fecha_vencimiento = fecha_vencimiento || (fecha_emision + 30.days)
        @subtotal = subtotal
        @impuestos = impuestos
        @total = total
        @estado = estado
        @items = items
        @created_at = created_at
        @updated_at = updated_at
      end

      def valid?
        numero.present? && cliente_id.present? && fecha_emision.present? && 
        subtotal > 0 && total > 0 && items.any?
      end

      def calcular_totales
        @subtotal = items.sum(&:subtotal)
        @impuestos = @subtotal * 0.19 # IVA 19%
        @total = @subtotal + @impuestos
      end

      def agregar_item(item)
        @items << item
        calcular_totales
      end

      def to_hash
        {
          id: id,
          numero: numero,
          cliente_id: cliente_id,
          fecha_emision: fecha_emision,
          fecha_vencimiento: fecha_vencimiento,
          subtotal: subtotal,
          impuestos: impuestos,
          total: total,
          estado: estado,
          items: items.map(&:to_hash),
          created_at: created_at,
          updated_at: updated_at
        }
      end
    end
  end
end