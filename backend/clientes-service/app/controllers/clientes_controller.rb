require_relative '../services/cliente_service'
require_relative '../repositories/cliente_repository_impl'
require_relative '../services/audit_logger'
require_relative '../../lib/domain/entities/cliente'
require_relative '../../lib/domain/repositories/cliente_repository'

class ClientesController < ApplicationController
  before_action :set_cliente_service
  before_action :set_audit_logger

  def index
    result = @cliente_service.listar_clientes
    if result[:success]
      @audit_logger.log_read('clientes-service', 'cliente', nil, {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'list_all' },
        response_data: { count: result[:data].length }
      })
      render json: { clientes: result[:data] }, status: :ok
    else
      @audit_logger.log_error('clientes-service', 'cliente', nil, result[:error], {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'list_all' }
      })
      render json: { error: result[:error] }, status: :internal_server_error
    end
  end

  def show
    result = @cliente_service.obtener_cliente(params[:id])
    if result[:success]
      @audit_logger.log_show('clientes-service', 'cliente', params[:id], {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'show', cliente_id: params[:id] },
        response_data: { cliente: result[:data] }
      })
      render json: { cliente: result[:data] }, status: :ok
    else
      @audit_logger.log_error('clientes-service', 'cliente', params[:id], result[:error], {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'show', cliente_id: params[:id] }
      })
      render json: { error: result[:error] }, status: :not_found
    end
  end

  def create
    result = @cliente_service.crear_cliente(cliente_params)
    if result[:success]
      @audit_logger.log_creation('clientes-service', 'cliente', result[:data].id, {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'create', cliente_data: cliente_params },
        response_data: { cliente: result[:data] }
      })
      render json: { cliente: result[:data] }, status: :created
    else
      @audit_logger.log_error('clientes-service', 'cliente', nil, result[:error], {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'create', cliente_data: cliente_params }
      })
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  def update
    result = @cliente_service.actualizar_cliente(params[:id], cliente_params)
    if result[:success]
      @audit_logger.log_update('clientes-service', 'cliente', params[:id], {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'update', cliente_data: cliente_params },
        response_data: { cliente: result[:data] }
      })
      render json: { cliente: result[:data] }, status: :ok
    else
      @audit_logger.log_error('clientes-service', 'cliente', params[:id], result[:error], {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'update', cliente_data: cliente_params }
      })
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  def destroy
    result = @cliente_service.eliminar_cliente(params[:id])
    if result[:success]
      @audit_logger.log_delete('clientes-service', 'cliente', params[:id], {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'destroy', cliente_id: params[:id] }
      })
      render json: result[:data], status: :ok
    else
      @audit_logger.log_error('clientes-service', 'cliente', params[:id], result[:error], {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_data: { action: 'destroy', cliente_id: params[:id] }
      })
      render json: { error: result[:error] }, status: :not_found
    end
  end

  private 

  def set_cliente_service
    @cliente_service = ClienteService.new(
      ClienteRepositoryImpl.new
    )
  end

  def set_audit_logger
    @audit_logger = AuditLogger.new
  end

  def cliente_params
    params.require(:cliente).permit(:nombre, :identificacion, :email, :direccion)
  end
end