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

  def actualizar_cliente(id, cliente_params)
    # Verificar que el cliente existe
    cliente = @cliente_repository.find_by_id(id)
    unless cliente
      return { success: false, error: "Cliente no encontrado" }
    end

    # Verificar si la identificación ya existe en otro cliente
    if cliente_params[:identificacion].present? && 
       cliente_params[:identificacion] != cliente.identificacion
      existing_cliente = @cliente_repository.find_by_identificacion(cliente_params[:identificacion])
      if existing_cliente && existing_cliente.id.to_s != id.to_s
        return { success: false, error: "Ya existe otro cliente con esta identificación" }
      end
    end

    begin
      updated_cliente = Domain::Entities::Cliente.new(
        id: id,
        nombre: cliente_params[:nombre] || cliente.nombre,
        identificacion: cliente_params[:identificacion] || cliente.identificacion,
        email: cliente_params[:email] || cliente.email,
        direccion: cliente_params[:direccion] || cliente.direccion
      )
      
      unless updated_cliente.valid?
        return { success: false, error: "Nombre e identificación son requeridos" }
      end

      saved_cliente = @cliente_repository.save(updated_cliente)
      { success: true, data: saved_cliente }
    rescue => e
      return { success: false, error: e.message }
    end
  end

  def eliminar_cliente(id)
    begin
      cliente = @cliente_repository.find_by_id(id)
      unless cliente
        return { success: false, error: "Cliente no encontrado" }
      end

      @cliente_repository.delete(id)
      { success: true, data: { id: id, message: "Cliente eliminado correctamente" } }
    rescue => e
      return { success: false, error: e.message }
    end
  end
  
end