module Domain
  module Repositories
    class AuditLogRepository
      def save(audit_log)
        raise NotImplementedError, "Guardar un log de auditoría debe ser implementado por la clase hija"
      end

      def find_by_id(id)
        raise NotImplementedError, "Buscar un log por id debe ser implementado por la clase hija"
      end

      def find_by_service(service_name)
        raise NotImplementedError, "Buscar logs por servicio debe ser implementado por la clase hija"
      end

      def find_by_resource(resource_type, resource_id)
        raise NotImplementedError, "Buscar logs por recurso debe ser implementado por la clase hija"
      end

      def find_by_action(action)
        raise NotImplementedError, "Buscar logs por acción debe ser implementado por la clase hija"
      end

      def find_by_date_range(start_date, end_date)
        raise NotImplementedError, "Buscar logs por rango de fechas debe ser implementado por la clase hija"
      end

      def find_by_user(user_id)
        raise NotImplementedError, "Buscar logs por usuario debe ser implementado por la clase hija"
      end

      def find_errors
        raise NotImplementedError, "Buscar logs de error debe ser implementado por la clase hija"
      end

      def all(limit: 100, offset: 0)
        raise NotImplementedError, "Listar todos los logs debe ser implementado por la clase hija"
      end

      def count
        raise NotImplementedError, "Contar logs debe ser implementado por la clase hija"
      end

      def delete_old_logs(days_old)
        raise NotImplementedError, "Eliminar logs antiguos debe ser implementado por la clase hija"
      end
    end
  end
end