require_relative '../services/factura_service'
require_relative '../repositories/factura_repository_impl'
require_relative '../services/cliente_service'
require_relative '../services/audit_logger'
require_relative '../../lib/domain/entities/factura'
require_relative '../../lib/domain/entities/item_factura'

class FacturasController < ApplicationController
  before_action :set_factura_service
  before_action :set_audit_logger

  def index
    if params[:fechaInicio].present? && params[:fechaFin].present?
      result = @factura_service.listar_facturas_por_fecha(params[:fechaInicio], params[:fechaFin])
      action_type = 'list_by_date_range'
    elsif params[:cliente_id].present?
      result = @factura_service.listar_facturas_por_cliente(params[:cliente_id])
      action_type = 'list_by_cliente'
    else
      result = @factura_service.listar_facturas
      action_type = 'list_all'
    end

    if result[:success]
      @audit_logger.log_read('facturas-service', 'factura', nil, {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { 
          action: action_type,
          fechaInicio: params[:fechaInicio],
          fechaFin: params[:fechaFin],
          cliente_id: params[:cliente_id]
        },
        response_data: { count: result[:data].length }
      })
      render json: { facturas: result[:data] }, status: :ok
    else
      @audit_logger.log_error('facturas-service', 'factura', nil, result[:error], {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { 
          action: action_type,
          fechaInicio: params[:fechaInicio],
          fechaFin: params[:fechaFin],
          cliente_id: params[:cliente_id]
        }
      })
      render json: { error: result[:error] }, status: :bad_request
    end
  end

  def show
    result = @factura_service.obtener_factura(params[:id])
    if result[:success]
      @audit_logger.log_show('facturas-service', 'factura', params[:id], {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'show', factura_id: params[:id] },
        response_data: { factura: result[:data] }
      })
      render json: { factura: result[:data] }, status: :ok
    else
      @audit_logger.log_error('facturas-service', 'factura', params[:id], result[:error], {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'show', factura_id: params[:id] }
      })
      render json: { error: result[:error] }, status: :not_found
    end
  end

  def create
    result = @factura_service.crear_factura(factura_params)
    if result[:success]
      @audit_logger.log_creation('facturas-service', 'factura', result[:data].id, {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'create', factura_data: factura_params },
        response_data: { factura: result[:data] }
      })
      render json: { factura: result[:data] }, status: :created
    else
      @audit_logger.log_error('facturas-service', 'factura', nil, result[:error], {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'create', factura_data: factura_params }
      })
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  private

  def set_factura_service
    @factura_service = FacturaService.new(
      FacturaRepositoryImpl.new,
      ClienteService.new
    )
  end

  def set_audit_logger
    @audit_logger = AuditLogger.new
  end

  def factura_params
    params.require(:factura).permit(
      :cliente_id,
      :numero,
      :fecha_emision,
      :subtotal,
      :impuestos,
      :total,
      :estado,
      items: [:descripcion, :cantidad, :precio_unitario, :subtotal]
    )
  end
end