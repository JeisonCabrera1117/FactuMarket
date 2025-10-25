module Domain
  module Repositories
    class ClienteRepository
      def find_by_id(id)
        raise NotImplementedError, "Buscar un cliente por id debe ser implementado por la clase hija"
      end

      def find_by_identificacion(identificacion)
        raise NotImplementedError, "Buscar un cliente por identificacion debe ser implementado por la clase hija"
      end

      def save(cliente)
        raise NotImplementedError, "Guardar un cliente debe ser implementado por la clase hija"
      end
  
      def all
        raise NotImplementedError, "Listar todos los clientes debe ser implementado por la clase hija"
      end
  
      def delete(id)
        raise NotImplementedError, "Eliminar un cliente debe ser implementado por la clase hija"
      end
    end
  end
end