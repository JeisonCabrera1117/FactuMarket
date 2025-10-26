require_relative '../../lib/domain/entities/cliente'

class ClienteService
  def initialize(cliente_repository)
    @cliente_repository = cliente_repository
  end
  

  def crear_cliente(cliente_params)
    cliente = Domain::Entities::Cliente.new(
      id: nil,
      nombre: cliente_params[:nombre],
      identificacion: cliente_params[:identificacion],
      email: cliente_params[:email],
      direccion: cliente_params[:direccion]
    )
    
    unless cliente.valid?
      return { success: false, error: "Nombre e identificación son requeridos" }
    end

    existing_cliente = @cliente_repository.find_by_identificacion(cliente.identificacion)
    if existing_cliente
      return { success: false, error: "Ya existe un cliente con esta identificación" }
    end

    begin
      saved_cliente = @cliente_repository.save(cliente)
      { success: true, data: saved_cliente }
    rescue => e
      return { success: false, error: e.message }
    end
  end

  def obtener_cliente(id)
    begin
      cliente = @cliente_repository.find_by_id(id)
      if cliente
        return { success: true, data: cliente }
      else
        return { success: false, error: "Cliente no encontrado" }
      end
    rescue => e
      return { success: false, error: e.message }
    end
  end

  def listar_clientes
    begin
      clientes = @cliente_repository.all
      { success: true, data: clientes }
    rescue => e
      return { success: false, error: e.message }
    end
  end

  
end