require_relative '../../lib/domain/entities/audit_log'

class AuditService
  def initialize(audit_log_repository)
    @audit_log_repository = audit_log_repository
  end

  def log_event(event_params)
    audit_log = Domain::Entities::AuditLog.new(
      service_name: event_params[:service_name],
      action: event_params[:action],
      resource_type: event_params[:resource_type],
      resource_id: event_params[:resource_id],
      user_id: event_params[:user_id],
      ip_address: event_params[:ip_address],
      user_agent: event_params[:user_agent],
      request_data: event_params[:request_data] || {},
      response_data: event_params[:response_data] || {},
      status: event_params[:status] || 'success',
      error_message: event_params[:error_message],
      timestamp: event_params[:timestamp] || Time.current
    )

    unless audit_log.valid?
      return { success: false, error: "Datos de auditoría inválidos" }
    end

    begin
      saved_log = @audit_log_repository.save(audit_log)
      { success: true, data: saved_log }
    rescue => e
      { success: false, error: e.message }
    end
  end

  def get_logs_by_service(service_name)
    begin
      logs = @audit_log_repository.find_by_service(service_name)
      { success: true, data: logs }
    rescue => e
      { success: false, error: e.message }
    end
  end

  def get_logs_by_resource(resource_type, resource_id)
    begin
      logs = @audit_log_repository.find_by_resource(resource_type, resource_id)
      { success: true, data: logs }
    rescue => e
      { success: false, error: e.message }
    end
  end

  def get_logs_by_action(action)
    begin
      logs = @audit_log_repository.find_by_action(action)
      { success: true, data: logs }
    rescue => e
      { success: false, error: e.message }
    end
  end

  def get_logs_by_date_range(start_date, end_date)
    begin
      logs = @audit_log_repository.find_by_date_range(start_date, end_date)
      { success: true, data: logs }
    rescue => e
      { success: false, error: e.message }
    end
  end

  def get_logs_by_user(user_id)
    begin
      logs = @audit_log_repository.find_by_user(user_id)
      { success: true, data: logs }
    rescue => e
      { success: false, error: e.message }
    end
  end

  def get_error_logs
    begin
      logs = @audit_log_repository.find_errors
      { success: true, data: logs }
    rescue => e
      { success: false, error: e.message }
    end
  end

  def get_all_logs(limit: 100, offset: 0)
    begin
      logs = @audit_log_repository.all(limit: limit, offset: offset)
      total_count = @audit_log_repository.count
      { 
        success: true, 
        data: logs, 
        pagination: {
          total: total_count,
          limit: limit,
          offset: offset,
          has_more: (offset + limit) < total_count
        }
      }
    rescue => e
      { success: false, error: e.message }
    end
  end

  def get_log_by_id(id)
    begin
      log = @audit_log_repository.find_by_id(id)
      if log
        { success: true, data: log }
      else
        { success: false, error: "Log de auditoría no encontrado" }
      end
    rescue => e
      { success: false, error: e.message }
    end
  end

  def cleanup_old_logs(days_old = 90)
    begin
      deleted_count = @audit_log_repository.delete_old_logs(days_old)
      { success: true, data: { deleted_count: deleted_count } }
    rescue => e
      { success: false, error: e.message }
    end
  end
end