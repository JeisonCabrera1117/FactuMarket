require_relative 'http_client'

class ClienteService
  def initialize
    @base_url = ENV.fetch('CLIENTES_SERVICE_URL', 'http://clientes-service:3000')
    @http_client = HttpClient.new(@base_url, 'clientes-service')
  end

  def obtener_cliente(cliente_id)
    result = @http_client.get("/clientes/#{cliente_id}")
    
    if result[:success]
      { success: true, data: result[:data]['cliente'] }
    else
      result
    end
  end

  def listar_clientes
    result = @http_client.get('/clientes')
    
    if result[:success]
      { success: true, data: result[:data]['clientes'] }
    else
      result
    end
  end
end