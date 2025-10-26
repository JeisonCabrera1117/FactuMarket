# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Facturas API', type: :request do
  let(:valid_factura_params) do
    {
      factura: {
        cliente_id: 1,
        fecha_emision: '2024-12-01',
        items: [
          {
            descripcion: 'Producto de prueba',
            cantidad: 2,
            precio_unitario: 100.0
          }
        ]
      }
    }
  end

  let(:invalid_factura_params) do
    {
      factura: {
        cliente_id: nil,
        fecha_emision: '2024-12-01',
        items: []
      }
    }
  end

  describe 'POST /facturas' do
    context 'con parámetros válidos' do
      it 'crea una nueva factura' do
        # Mock del servicio de clientes
        allow_any_instance_of(ClienteService)
          .to receive(:obtener_cliente).with(1)
          .and_return({ success: true, data: { id: 1, nombre: 'Cliente Test' } })

        # Mock del repositorio para simular guardado
        allow_any_instance_of(FacturaRepositoryImpl)
          .to receive(:save).and_return(double(
            id: 1,
            numero: 'FAC-20241201-ABC123',
            cliente_id: 1,
            total: 238.0,
            items: []
          ))

        post '/facturas', params: valid_factura_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include('factura')
      end
    end

    context 'con parámetros inválidos' do
      it 'retorna error 422' do
        post '/facturas', params: invalid_factura_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('error')
      end
    end

    context 'cuando el cliente no existe' do
      it 'retorna error 422' do
        allow_any_instance_of(ClienteService)
          .to receive(:obtener_cliente).with(999)
          .and_return({ success: false, error: 'Cliente no encontrado' })

        valid_factura_params[:factura][:cliente_id] = 999

        post '/facturas', params: valid_factura_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('error')
      end
    end
  end

  describe 'GET /facturas/:id' do
    let(:factura) { create(:factura) }

    it 'retorna la factura solicitada' do
      get "/facturas/#{factura.id}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('factura')
    end

    it 'retorna 404 si la factura no existe' do
      get '/facturas/999'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /facturas' do
    it 'retorna facturas por rango de fechas' do
      get '/facturas', params: {
        fechaInicio: '2024-12-01',
        fechaFin: '2024-12-31'
      }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('facturas')
    end

    it 'retorna error 400 con parámetros inválidos' do
      get '/facturas', params: {
        fechaInicio: '2024-12-31',
        fechaFin: '2024-12-01'
      }

      expect(response).to have_http_status(:bad_request)
    end
  end
end