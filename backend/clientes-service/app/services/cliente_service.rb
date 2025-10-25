require_relative '../../lib/domain/entities/cliente'

class ClienteService
  def initialize(cliente_repository, auditoria_service)
    @cliente_repository = cliente_repository
    @auditoria_service = auditoria_service
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
      return { success: false, errors: ["Nombre e identificación son requeridos"] }
    end

    existing_cliente = @cliente_repository.find_by_identificacion(cliente.identificacion)
    if existing_cliente
      return { success: false, errors: ["Ya existe un cliente con esta identificación"] }
    end

    begin
      saved_cliente = @cliente_repository.save(cliente)
      
      # Registrar evento de auditoría
      @auditoria_service.registrar_evento(
        tipo: 'cliente_creado',
        entidad_id: saved_cliente.id,
        datos: saved_cliente.to_hash
      )
      
      { success: true, data: saved_cliente }
    rescue => e
      return { success: false, errors: [e.message] }
    end
  end

  def obtener_cliente(id)
    begin
      cliente = @cliente_repository.find_by_id(id)
      if cliente
        # Registrar evento de auditoría
        @auditoria_service.registrar_evento(
          tipo: 'cliente_consultado',
          entidad_id: id,
          datos: {}
        )
        return { success: true, data: cliente }
      else
        return { success: false, errors: ["Cliente no encontrado"] }
      end
    rescue => e
      return { success: false, errors: [e.message] }
    end
  end

  def listar_clientes
    begin
      clientes = @cliente_repository.all
      
      # Registrar evento de auditoría
      @auditoria_service.registrar_evento(
        tipo: 'clientes_listados',
        entidad_id: nil,
        datos: {}
      )
      
      { success: true, data: clientes }
    rescue => e
      return { success: false, errors: [e.message] }
    end
  end

  
end