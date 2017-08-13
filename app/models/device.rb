class Device < ActiveRecord::Base
  include DeviceStatus

  belongs_to :model
  has_one :brand, through: :model
  has_many :macs, dependent: :delete_all
  has_many :ips, dependent: :delete_all
  has_and_belongs_to_many :groups
  belongs_to :plugin, polymorphic: true
  has_many :heartbeats, dependent: :delete_all
  has_many :device_actions
  has_many :operating_system_histories
  has_many :operating_systems, through: :operating_system_histories
  has_and_belongs_to_many :hive_queues
  accepts_nested_attributes_for :groups
  has_many :relationships, foreign_key: :primary_id
  has_many :related_devices, through: :relationships, foreign_key: :primary_id, primary_key: :secondary_id, class_name: 'Device', source: :secondary
  has_many :device_statistics
  has_many :device_states

  scope :classification, ->(classification) { joins(model: :device_type).where('device_types.classification=?', classification) }

  def mac_addresses
    macs.map(&:mac)
  end

  def ip_addresses
    ips.map(&:ip)
  end

  def latest_stat(options)
    if stat = device_statistics.where(label: options[:label]).order(:timestamp).last
      stat.value
    else
      options[:default] || nil
    end
  end

  def details
    details = plugin && plugin.methods.include?(:details) ? plugin.details : {}
    {
      brand: model && model.brand && model.brand.name,
      model: model && model.name,
      macs: mac_addresses,
      ips: ip_addresses
    }.merge(details)
  end

  def device_type
    model && model.device_type && model.device_type.classification
  end

  def heartbeat(options = {})
    Heartbeat.create(
      device: self,
      reporting_device: (options.key?(:reported_by) ? options[:reported_by] : self)
    )
  end

  def seconds_since_heartbeat
    if !@seconds_since_heartbeat && hb = heartbeats.last
      @seconds_since_heartbeat = (Time.now - hb.created_at).to_i
    end
    @seconds_since_heartbeat
  end

  def execute_action
    if ac = device_actions.where(executed_at: nil).first
      ac.update(executed_at: Time.now)
    end
    ac
  end

  def add_relation(relation, secondary)
    Relationship.find_or_create_by(
      primary: self,
      secondary: secondary,
      relation: relation
    )
  end

  def delete_relation(relation, secondary)
    Relationship.delete_all(
      primary: self,
      secondary: secondary,
      relation: relation
    )
  end

  def plugin_json_keys
    plugin && plugin.methods.include?(:json_keys) ? plugin.json_keys : []
  end

  def self.identify_existing(options = {})
    if options.key?(:device_type)
      begin
        plugin_type = options[:device_type].casecmp('tablet').zero? ? 'Mobile' : options[:device_type]
        obj = Object.const_get("HiveMind#{plugin_type.capitalize}::Plugin")
        if obj.methods.include? :identify_existing
          return obj.identify_existing(options)
        end
      rescue NameError
        logger.info 'Unknown device type'
      end
    end

    if options.key?(:macs)
      options[:macs].compact.each do |m|
        return Device.find(m.device_id) if m.device_id
      end
    end
    nil
  end

  def set_os(options = {})
    os = OperatingSystem.find_or_create_by(name: options[:name], version: options[:version])
    if os != operating_system
      operating_system_histories.select { |o| o.end_timestamp.nil? }.each do |osh|
        osh.end_timestamp = Time.now
        osh.save
      end
      OperatingSystemHistory.create(
        device: self,
        operating_system: os,
        start_timestamp: Time.now
      )
      reload
    end
  end

  def operating_system
    # Note, .last gets the most recently created entry in the OperatingSystem
    # model and this is not necessarily the latest in the history of the device
    operating_systems[-1]
  end
end
