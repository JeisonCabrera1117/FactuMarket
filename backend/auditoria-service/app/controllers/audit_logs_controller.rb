require_relative '../services/audit_service'
require_relative '../repositories/audit_log_repository_impl'

class AuditLogsController < ApplicationController
  before_action :set_audit_service

  # POST /audit_logs - Crear un nuevo log de auditoría
  def create
    result = @audit_service.log_event(audit_log_params)
    if result[:success]
      render json: { audit_log: result[:data] }, status: :created
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  # GET /audit_logs/:id - Obtener un log específico
  def show
    result = @audit_service.get_log_by_id(params[:id])
    if result[:success]
      render json: { audit_log: result[:data] }, status: :ok
    else
      render json: { error: result[:error] }, status: :not_found
    end
  end

  # GET /audit_logs - Listar logs con filtros
  def index
    if params[:service_name].present?
      result = @audit_service.get_logs_by_service(params[:service_name])
    elsif params[:resource_type].present? && params[:resource_id].present?
      result = @audit_service.get_logs_by_resource(params[:resource_type], params[:resource_id])
    elsif params[:action].present?
      result = @audit_service.get_logs_by_action(params[:action])
    elsif params[:user_id].present?
      result = @audit_service.get_logs_by_user(params[:user_id])
    elsif params[:start_date].present? && params[:end_date].present?
      result = @audit_service.get_logs_by_date_range(params[:start_date], params[:end_date])
    elsif params[:errors] == 'true'
      result = @audit_service.get_error_logs
    else
      limit = params[:limit]&.to_i || 100
      offset = params[:offset]&.to_i || 0
      result = @audit_service.get_all_logs(limit: limit, offset: offset)
    end

    if result[:success]
      response_data = { audit_logs: result[:data] }
      response_data[:pagination] = result[:pagination] if result[:pagination]
      render json: response_data, status: :ok
    else
      render json: { error: result[:error] }, status: :bad_request
    end
  end

  # DELETE /audit_logs/cleanup - Limpiar logs antiguos
  def cleanup
    days_old = params[:days_old]&.to_i || 90
    result = @audit_service.cleanup_old_logs(days_old)
    if result[:success]
      render json: { message: "Se eliminaron #{result[:data][:deleted_count]} logs antiguos" }, status: :ok
    else
      render json: { error: result[:error] }, status: :internal_server_error
    end
  end

  private

  def set_audit_service
    @audit_service = AuditService.new(
      AuditLogRepositoryImpl.new
    )
  end

  def audit_log_params
    params.require(:audit_log).permit(
      :service_name, :action, :resource_type, :resource_id, :user_id,
      :ip_address, :user_agent, :status, :error_message, :timestamp,
      request_data: {}, response_data: {}
    )
  end
end