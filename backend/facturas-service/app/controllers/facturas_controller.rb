require_relative '../services/factura_service'
require_relative '../repositories/factura_repository_impl'
require_relative '../services/cliente_service'
require_relative '../../lib/domain/entities/factura'
require_relative '../../lib/domain/entities/item_factura'

class FacturasController < ApplicationController
  before_action :set_factura_service

  def index
    if params[:fechaInicio].present? && params[:fechaFin].present?
      result = @factura_service.listar_facturas_por_fecha(params[:fechaInicio], params[:fechaFin])
    elsif params[:cliente_id].present?
      result = @factura_service.listar_facturas_por_cliente(params[:cliente_id])
    else
      result = @factura_service.listar_facturas
    end

    if result[:success]
      render json: { facturas: result[:data] }, status: :ok
    else
      render json: { error: result[:error] }, status: :bad_request
    end
  end

  def show
    result = @factura_service.obtener_factura(params[:id])
    if result[:success]
      render json: { factura: result[:data] }, status: :ok
    else
      render json: { error: result[:error] }, status: :not_found
    end
  end

  def create
    result = @factura_service.crear_factura(factura_params)
    if result[:success]
      render json: { factura: result[:data] }, status: :created
    else
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

  def factura_params
    params.require(:factura).permit(
      :cliente_id,
      :fecha_emision,
      items: [:descripcion, :cantidad, :precio_unitario]
    )
  end
end