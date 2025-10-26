require_relative '../../lib/domain/entities/audit_log'
require_relative '../../lib/domain/repositories/audit_log_repository'

class AuditLogRepositoryImpl < Domain::Repositories::AuditLogRepository
  def save(audit_log)
    begin
      mongo_doc = AuditLog.from_domain_entity(audit_log)
      if mongo_doc.save
        mongo_doc.to_domain_entity
      else
        raise StandardError, "Error al guardar el log de auditoría: #{mongo_doc.errors.full_messages.join(', ')}"
      end
    rescue => e
      raise StandardError, "Error al guardar el log de auditoría: #{e.message}"
    end
  end

  def find_by_id(id)
    begin
      mongo_doc = AuditLog.find(id)
      mongo_doc.to_domain_entity
    rescue Mongoid::Errors::DocumentNotFound
      nil
    rescue => e
      raise StandardError, "Error al buscar el log de auditoría: #{e.message}"
    end
  end

  def find_by_service(service_name)
    begin
      mongo_docs = AuditLog.by_service(service_name).recent.limit(100)
      mongo_docs.map(&:to_domain_entity)
    rescue => e
      raise StandardError, "Error al buscar logs por servicio: #{e.message}"
    end
  end

  def find_by_resource(resource_type, resource_id)
    begin
      mongo_docs = AuditLog.by_resource(resource_type, resource_id).recent.limit(100)
      mongo_docs.map(&:to_domain_entity)
    rescue => e
      raise StandardError, "Error al buscar logs por recurso: #{e.message}"
    end
  end

  def find_by_action(action)
    begin
      mongo_docs = AuditLog.by_action(action).recent.limit(100)
      mongo_docs.map(&:to_domain_entity)
    rescue => e
      raise StandardError, "Error al buscar logs por acción: #{e.message}"
    end
  end

  def find_by_date_range(start_date, end_date)
    begin
      mongo_docs = AuditLog.by_date_range(start_date, end_date).recent.limit(1000)
      mongo_docs.map(&:to_domain_entity)
    rescue => e
      raise StandardError, "Error al buscar logs por rango de fechas: #{e.message}"
    end
  end

  def find_by_user(user_id)
    begin
      mongo_docs = AuditLog.by_user(user_id).recent.limit(100)
      mongo_docs.map(&:to_domain_entity)
    rescue => e
      raise StandardError, "Error al buscar logs por usuario: #{e.message}"
    end
  end

  def find_errors
    begin
      mongo_docs = AuditLog.errors.recent.limit(100)
      mongo_docs.map(&:to_domain_entity)
    rescue => e
      raise StandardError, "Error al buscar logs de error: #{e.message}"
    end
  end

  def all(limit: 100, offset: 0)
    begin
      mongo_docs = AuditLog.recent.skip(offset).limit(limit)
      mongo_docs.map(&:to_domain_entity)
    rescue => e
      raise StandardError, "Error al listar logs: #{e.message}"
    end
  end

  def count
    begin
      AuditLog.count
    rescue => e
      raise StandardError, "Error al contar logs: #{e.message}"
    end
  end

  def delete_old_logs(days_old)
    begin
      cutoff_date = days_old.days.ago
      deleted_count = AuditLog.where(:created_at.lt => cutoff_date).delete_all
      deleted_count
    rescue => e
      raise StandardError, "Error al eliminar logs antiguos: #{e.message}"
    end
  end
end