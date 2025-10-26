require 'net/http'
require 'uri'
require 'json'

class AuditLogger
  def initialize(auditoria_service_url = ENV['AUDITORIA_SERVICE_URL'])
    @auditoria_service_url = auditoria_service_url
  end

  def log_event(service_name, action, resource_type, resource_id = nil, options = {})
    return unless @auditoria_service_url.present?

    audit_data = {
      audit_log: {
        service_name: service_name,
        action: action,
        resource_type: resource_type,
        resource_id: resource_id,
        user_id: options[:user_id],
        ip_address: options[:ip_address],
        user_agent: options[:user_agent],
        request_data: options[:request_data] || {},
        response_data: options[:response_data] || {},
        status: options[:status] || 'success',
        error_message: options[:error_message],
        timestamp: options[:timestamp] || Time.current.iso8601
      }
    }

    begin
      uri = URI("#{@auditoria_service_url}/audit_logs")
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 5
      http.open_timeout = 2

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = audit_data.to_json

      response = http.request(request)
      
      if response.code.to_i >= 400
        Rails.logger.error "Error al enviar log de auditoría: #{response.code} - #{response.body}"
      end
    rescue => e
      Rails.logger.error "Error al conectar con servicio de auditoría: #{e.message}"
    end
  end

  def log_creation(service_name, resource_type, resource_id, options = {})
    log_event(service_name, 'create', resource_type, resource_id, options)
  end

  def log_read(service_name, resource_type, resource_id, options = {})
    log_event(service_name, 'read', resource_type, resource_id, options)
  end

  def log_show(service_name, resource_type, resource_id, options = {})
    log_event(service_name, 'show', resource_type, resource_id, options)
  end

  def log_update(service_name, resource_type, resource_id, options = {})
    log_event(service_name, 'update', resource_type, resource_id, options)
  end

  def log_delete(service_name, resource_type, resource_id, options = {})
    log_event(service_name, 'delete', resource_type, resource_id, options)
  end

  def log_error(service_name, resource_type, resource_id, error_message, options = {})
    log_event(service_name, 'error', resource_type, resource_id, options.merge(
      status: 'error',
      error_message: error_message
    ))
  end
end