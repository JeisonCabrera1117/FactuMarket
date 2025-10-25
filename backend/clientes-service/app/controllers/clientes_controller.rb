require_relative '../services/cliente_service'
require_relative '../repositories/cliente_repository_impl'
require_relative '../../lib/domain/entities/cliente'
require_relative '../../lib/domain/repositories/cliente_repository'

class ClientesController < ApplicationController
  before_action :set_cliente_service

  def index
    result = @cliente_service.listar_clientes
    if result[:success]
      render json: { clientes: result[:data] }, status: :ok
    else
      render json: { error: result[:error] }, status: :internal_server_error
    end
  end

  def show
    result = @cliente_service.obtener_cliente(params[:id])
    if result[:success]
      render json: { cliente: result[:data] }, status: :ok
    else
      render json: { error: result[:error] }, status: :not_found
    end
  end

  def create
    result = @cliente_service.crear_cliente(cliente_params)
    if result[:success]
      render json: { cliente: result[:data] }, status: :created
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  private 

  def set_cliente_service
    @cliente_service = ClienteService.new(
      ClienteRepositoryImpl.new
    )
  end

  def cliente_params
    params.require(:cliente).permit(:nombre, :identificacion, :email, :direccion)
  end
end