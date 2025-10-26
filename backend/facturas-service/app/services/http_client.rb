require 'net/http'
require 'json'

class HttpClient
  def initialize(base_url, service_name = 'unknown')
    @base_url = base_url
    @service_name = service_name
  end

  def get(path, headers = {})
    make_request(:get, path, nil, headers)
  end

  def post(path, body = nil, headers = {})
    make_request(:post, path, body, headers)
  end

  def put(path, body = nil, headers = {})
    make_request(:put, path, body, headers)
  end

  def delete(path, headers = {})
    make_request(:delete, path, nil, headers)
  end

  private

  def make_request(method, path, body = nil, headers = {})
    uri = URI("#{@base_url}#{path}")
    
    begin
      http = create_http_connection(uri)
      request = create_request(method, uri, body, headers)
      response = http.request(request)
      
      handle_response(response)
      
    rescue Net::TimeoutError => e
      { success: false, error: "Timeout al conectar con #{@service_name}" }
    rescue Net::ConnectionError => e
      { success: false, error: "Error de conexión con #{@service_name}" }
    rescue => e
      { success: false, error: "Error inesperado: #{e.message}" }
    end
  end

  def create_http_connection(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.read_timeout = ENV.fetch('HTTP_READ_TIMEOUT', 10).to_i
    http.open_timeout = ENV.fetch('HTTP_OPEN_TIMEOUT', 5).to_i
    http
  end

  def create_request(method, uri, body, headers)
    request_class = case method
                   when :get then Net::HTTP::Get
                   when :post then Net::HTTP::Post
                   when :put then Net::HTTP::Put
                   when :delete then Net::HTTP::Delete
                   end

    request = request_class.new(uri)
    
    # Headers por defecto
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
    request['User-Agent'] = "FactuMarket-#{@service_name}/1.0"
    
    # Headers personalizados
    headers.each { |key, value| request[key] = value }
    
    # Body para POST/PUT
    if body && [:post, :put].include?(method)
      request.body = body.is_a?(Hash) ? body.to_json : body
    end
    
    request
  end

  def handle_response(response)
    case response.code.to_i
    when 200..299
      data = parse_json_response(response.body)
      { success: true, data: data, status: response.code.to_i }
    when 400
      error_data = parse_json_response(response.body)
      { success: false, error: error_data['error'] || 'Bad Request', status: 400 }
    when 404
      { success: false, error: 'Recurso no encontrado', status: 404 }
    when 422
      error_data = parse_json_response(response.body)
      { success: false, error: error_data['error'] || 'Unprocessable Entity', status: 422 }
    when 500..599
      { success: false, error: "Error interno del servidor #{@service_name}", status: response.code.to_i }
    else
      { success: false, error: "Error inesperado del servicio #{@service_name}", status: response.code.to_i }
    end
  end

  def parse_json_response(body)
    return {} if body.nil? || body.empty?
    
    JSON.parse(body)
  rescue JSON::ParserError => e
    { 'raw_response' => body }
  end
end