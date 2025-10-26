module Domain
  module Repositories
    class FacturaRepository
      def find_by_id(id)
        raise NotImplementedError, "Buscar una factura por id debe ser implementado por la clase hija"
      end

      def find_by_numero(numero)
        raise NotImplementedError, "Buscar una factura por numero debe ser implementado por la clase hija"
      end

      def find_by_cliente_id(cliente_id)
        raise NotImplementedError, "Buscar facturas por cliente_id debe ser implementado por la clase hija"
      end

      def find_by_fecha_range(fecha_inicio, fecha_fin)
        raise NotImplementedError, "Buscar facturas por rango de fechas debe ser implementado por la clase hija"
      end

      def save(factura)
        raise NotImplementedError, "Guardar una factura debe ser implementado por la clase hija"
      end

      def all
        raise NotImplementedError, "Listar todas las facturas debe ser implementado por la clase hija"
      end

      def delete(id)
        raise NotImplementedError, "Eliminar una factura debe ser implementado por la clase hija"
      end
    end
  end
end