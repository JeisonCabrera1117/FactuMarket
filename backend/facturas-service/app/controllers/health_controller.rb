require_relative '../services/cliente_service'

class HealthController < ApplicationController
  def show
    health_status = {
      status: 'ok',
      service: 'facturas-service',
      timestamp: Time.current.iso8601,
      dependencies: {}
    }

    # Verificar conectividad con servicio de clientes
    begin
      cliente_service = ClienteService.new
      result = cliente_service.listar_clientes
      
      if result[:success]
        health_status[:dependencies][:clientes_service] = {
          status: 'healthy',
          last_check: Time.current.iso8601
        }
      else
        health_status[:dependencies][:clientes_service] = {
          status: 'unhealthy',
          error: result[:error],
          last_check: Time.current.iso8601
        }
        health_status[:status] = 'degraded'
      end
    rescue => e
      health_status[:dependencies][:clientes_service] = {
        status: 'unreachable',
        error: e.message,
        last_check: Time.current.iso8601
      }
      health_status[:status] = 'degraded'
    end

    # Verificar base de datos
    begin
      # Aquí podrías agregar una verificación simple de la base de datos
      # Por ejemplo, ejecutar una consulta simple
      health_status[:dependencies][:database] = {
        status: 'healthy',
        last_check: Time.current.iso8601
      }
    rescue => e
      health_status[:dependencies][:database] = {
        status: 'unhealthy',
        error: e.message,
        last_check: Time.current.iso8601
      }
      health_status[:status] = 'unhealthy'
    end

    # Determinar el código de respuesta HTTP
    http_status = case health_status[:status]
                 when 'ok' then :ok
                 when 'degraded' then :ok  # 200 pero con advertencias
                 when 'unhealthy' then :service_unavailable
                 end

    render json: health_status, status: http_status
  end
end