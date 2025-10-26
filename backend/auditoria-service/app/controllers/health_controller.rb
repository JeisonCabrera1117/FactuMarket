class HealthController < ApplicationController
  def show
    begin
      # Verificar conexión a MongoDB
      mongo_status = check_mongodb_connection
      
      if mongo_status[:healthy]
        render json: {
          status: 'ok',
          service: 'auditoria-service',
          timestamp: Time.current.iso8601,
          dependencies: {
            mongodb: {
              status: 'healthy',
              last_check: Time.current.iso8601
            }
          }
        }, status: :ok
      else
        render json: {
          status: 'degraded',
          service: 'auditoria-service',
          timestamp: Time.current.iso8601,
          dependencies: {
            mongodb: {
              status: 'unhealthy',
              error: mongo_status[:error],
              last_check: Time.current.iso8601
            }
          }
        }, status: :service_unavailable
      end
    rescue => e
      render json: {
        status: 'unhealthy',
        service: 'auditoria-service',
        timestamp: Time.current.iso8601,
        error: e.message
      }, status: :internal_server_error
    end
  end

  private

  def check_mongodb_connection
    begin
      # Intentar una operación simple en MongoDB
      AuditLog.count
      { healthy: true }
    rescue => e
      { healthy: false, error: e.message }
    end
  end
end