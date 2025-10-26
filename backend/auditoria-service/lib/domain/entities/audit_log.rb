module Domain
  module Entities
    class AuditLog
      attr_reader :id, :service_name, :action, :resource_type, :resource_id, 
                  :user_id, :ip_address, :user_agent, :request_data, :response_data,
                  :status, :error_message, :timestamp, :created_at

      def initialize(
        id: nil,
        service_name:,
        action:,
        resource_type:,
        resource_id: nil,
        user_id: nil,
        ip_address: nil,
        user_agent: nil,
        request_data: {},
        response_data: {},
        status: 'success',
        error_message: nil,
        timestamp: Time.current,
        created_at: nil
      )
        @id = id
        @service_name = service_name
        @action = action
        @resource_type = resource_type
        @resource_id = resource_id
        @user_id = user_id
        @ip_address = ip_address
        @user_agent = user_agent
        @request_data = request_data
        @response_data = response_data
        @status = status
        @error_message = error_message
        @timestamp = timestamp
        @created_at = created_at
      end

      def valid?
        service_name.present? && action.present? && resource_type.present?
      end

      def success?
        status == 'success'
      end

      def error?
        status == 'error'
      end

      def to_hash
        {
          id: id,
          service_name: service_name,
          action: action,
          resource_type: resource_type,
          resource_id: resource_id,
          user_id: user_id,
          ip_address: ip_address,
          user_agent: user_agent,
          request_data: request_data,
          response_data: response_data,
          status: status,
          error_message: error_message,
          timestamp: timestamp,
          created_at: created_at
        }
      end

      def to_json
        to_hash.to_json
      end
    end
  end
end