require_relative '../../lib/domain/entities/factura'
require_relative '../../lib/domain/entities/item_factura'

class FacturaService
  def initialize(factura_repository, cliente_service)
    @factura_repository = factura_repository
    @cliente_service = cliente_service
  end

  def crear_factura(factura_params)
    # Validar que el cliente existe
    cliente_result = @cliente_service.obtener_cliente(factura_params[:cliente_id])
    unless cliente_result[:success]
      return { success: false, error: "Cliente no encontrado" }
    end

    # Crear items de la factura
    items = factura_params[:items].map do |item_data|
      Domain::Entities::ItemFactura.new(
        descripcion: item_data[:descripcion],
        cantidad: item_data[:cantidad],
        precio_unitario: item_data[:precio_unitario]
      )
    end

    # Crear la factura
    factura = Domain::Entities::Factura.new(
      id: nil,
      numero: generar_numero_factura,
      cliente_id: factura_params[:cliente_id],
      fecha_emision: Date.parse(factura_params[:fecha_emision]),
      items: items
    )

    # Calcular totales
    factura.calcular_totales

    unless factura.valid?
      return { success: false, error: "Datos de factura inválidos" }
    end

    begin
      saved_factura = @factura_repository.save(factura)
      { success: true, data: saved_factura }
    rescue => e
      { success: false, error: e.message }
    end
  end

  def obtener_factura(id)
    begin
      factura = @factura_repository.find_by_id(id)
      if factura
        return { success: true, data: factura }
      else
        return { success: false, error: "Factura no encontrada" }
      end
    rescue => e
      { success: false, error: e.message }
    end
  end

  def listar_facturas
    begin
      facturas = @factura_repository.all
      { success: true, data: facturas }
    rescue => e
      { success: false, error: e.message }
    end
  end

  def listar_facturas_por_fecha(fecha_inicio, fecha_fin)
    begin
      # Validar fechas
      fecha_inicio_obj = Date.parse(fecha_inicio)
      fecha_fin_obj = Date.parse(fecha_fin)
      
      if fecha_inicio_obj > fecha_fin_obj
        return { success: false, error: "fecha_inicio no puede ser mayor a fecha_fin" }
      end

      facturas = @factura_repository.find_by_fecha_range(fecha_inicio_obj, fecha_fin_obj)
      { success: true, data: facturas }
    rescue Date::Error
      { success: false, error: "Formato de fecha inválido" }
    rescue => e
      { success: false, error: e.message }
    end
  end

  def listar_facturas_por_cliente(cliente_id)
    begin
      facturas = @factura_repository.find_by_cliente_id(cliente_id)
      { success: true, data: facturas }
    rescue => e
      { success: false, error: e.message }
    end
  end

  def eliminar_factura(id)
    begin
      factura = @factura_repository.find_by_id(id)
      unless factura
        return { success: false, error: "Factura no encontrada" }
      end

      @factura_repository.delete(id)
      { success: true, data: { id: id, message: "Factura eliminada correctamente" } }
    rescue => e
      { success: false, error: e.message }
    end
  end

  private

  def generar_numero_factura
    "FAC-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end