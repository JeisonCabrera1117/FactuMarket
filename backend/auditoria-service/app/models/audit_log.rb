class AuditLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :service_name, type: String
  field :action, type: String
  field :resource_type, type: String
  field :resource_id, type: String
  field :user_id, type: String
  field :ip_address, type: String
  field :user_agent, type: String
  field :request_data, type: Hash, default: {}
  field :response_data, type: Hash, default: {}
  field :status, type: String, default: 'success'
  field :error_message, type: String
  field :timestamp, type: Time, default: -> { Time.current }

  # Índices para mejorar el rendimiento
  index({ service_name: 1 })
  index({ action: 1 })
  index({ resource_type: 1, resource_id: 1 })
  index({ user_id: 1 })
  index({ status: 1 })
  index({ timestamp: -1 })
  index({ created_at: -1 })

  # Validaciones
  validates :service_name, presence: true
  validates :action, presence: true
  validates :resource_type, presence: true
  validates :status, inclusion: { in: %w[success error] }

  # Scopes
  scope :by_service, ->(service_name) { where(service_name: service_name) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_resource, ->(resource_type, resource_id) { where(resource_type: resource_type, resource_id: resource_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :errors, -> { where(status: 'error') }
  scope :success, -> { where(status: 'success') }
  scope :recent, -> { order(timestamp: :desc) }
  scope :by_date_range, ->(start_date, end_date) { where(timestamp: start_date..end_date) }

  def to_domain_entity
    Domain::Entities::AuditLog.new(
      id: id.to_s,
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
    )
  end

  def self.from_domain_entity(audit_log_entity)
    new(
      service_name: audit_log_entity.service_name,
      action: audit_log_entity.action,
      resource_type: audit_log_entity.resource_type,
      resource_id: audit_log_entity.resource_id,
      user_id: audit_log_entity.user_id,
      ip_address: audit_log_entity.ip_address,
      user_agent: audit_log_entity.user_agent,
      request_data: audit_log_entity.request_data,
      response_data: audit_log_entity.response_data,
      status: audit_log_entity.status,
      error_message: audit_log_entity.error_message,
      timestamp: audit_log_entity.timestamp
    )
  end
end