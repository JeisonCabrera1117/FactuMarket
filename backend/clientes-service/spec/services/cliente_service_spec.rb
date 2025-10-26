require 'rails_helper'

RSpec.describe ClienteService do
  let(:cliente_repository) { double('ClienteRepository') }
  let(:service) { ClienteService.new(cliente_repository) }

  describe '#crear_cliente' do
    context 'con datos válidos' do
      let(:params) do
        {
          nombre: 'Empresa ABC S.A.S',
          identificacion: '900123456-7',
          email: 'contacto@empresaabc.com',
          direccion: 'Calle 123 #45-67, Bogotá'
        }
      end

      let(:cliente_entity) { double('ClienteEntity', identificacion: '900123456-7') }
      let(:saved_cliente) { double('SavedCliente', id: 1, to_hash: {}) }

      before do
        allow(Domain::Entities::Cliente).to receive(:new).and_return(cliente_entity)
        allow(cliente_entity).to receive(:valid?).and_return(true)
        allow(cliente_repository).to receive(:find_by_identificacion).and_return(nil)
        allow(cliente_repository).to receive(:save).and_return(saved_cliente)
      end

      it 'crea un cliente exitosamente' do
        result = service.crear_cliente(params)

        expect(result[:success]).to be true
        expect(result[:data]).to eq(saved_cliente)
      end

    end

    context 'con datos inválidos' do
      let(:params) { { nombre: '', identificacion: '' } }
      let(:cliente_entity) { double('ClienteEntity', identificacion: '') }

      before do
        allow(Domain::Entities::Cliente).to receive(:new).and_return(cliente_entity)
        allow(cliente_entity).to receive(:valid?).and_return(false)
      end

      it 'retorna error de validación' do
        result = service.crear_cliente(params)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Nombre e identificación son requeridos')
      end
    end

    context 'cuando ya existe un cliente con la misma identificación' do
      let(:params) do
        {
          nombre: 'Empresa ABC S.A.S',
          identificacion: '900123456-7'
        }
      end

      let(:cliente_entity) { double('ClienteEntity', identificacion: '900123456-7') }
      let(:existing_cliente) { double('ExistingCliente') }

      before do
        allow(Domain::Entities::Cliente).to receive(:new).and_return(cliente_entity)
        allow(cliente_entity).to receive(:valid?).and_return(true)
        allow(cliente_repository).to receive(:find_by_identificacion).and_return(existing_cliente)
      end

      it 'retorna error de duplicado' do
        result = service.crear_cliente(params)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Ya existe un cliente con esta identificación')
      end
    end
  end

  describe '#obtener_cliente' do
    let(:cliente_id) { 1 }
    let(:cliente_entity) { double('ClienteEntity', to_hash: {}) }

    context 'cuando el cliente existe' do
      before do
        allow(cliente_repository).to receive(:find_by_id).with(cliente_id).and_return(cliente_entity)
      end

      it 'retorna el cliente' do
        result = service.obtener_cliente(cliente_id)

        expect(result[:success]).to be true
        expect(result[:data]).to eq(cliente_entity)
      end
    end

    context 'cuando el cliente no existe' do
      before do
        allow(cliente_repository).to receive(:find_by_id).with(cliente_id).and_return(nil)
      end

      it 'retorna error de no encontrado' do
        result = service.obtener_cliente(cliente_id)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Cliente no encontrado')
      end
    end
  end

  describe '#listar_clientes' do
    let(:clientes) { [double('Cliente1'), double('Cliente2')] }

    before do
      allow(cliente_repository).to receive(:all).and_return(clientes)
    end

    it 'retorna la lista de clientes' do
      result = service.listar_clientes

      expect(result[:success]).to be true
      expect(result[:data]).to eq(clientes)
    end
  end
end
