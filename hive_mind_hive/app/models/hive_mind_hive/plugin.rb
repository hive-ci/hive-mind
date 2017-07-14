module HiveMindHive
  class Plugin < ActiveRecord::Base
    has_one :device, as: :plugin
    has_many :runner_version_history
    has_many :runner_plugin_version_history

    def self.create(*args)
      copy = ActionController::Parameters.new(args[0])
      args[0] = copy.permit(:hostname)
      %i[runner_version_history runner_plugin_version_history].each do |key|
        args[0][key] = copy[key] if copy.key?(key)
      end

      hive = super(*args)
      hive.update_version(copy['version']) if copy.key?('version')
      hive.update_runner_plugins(copy['runner_plugins']) if copy.key?('runner_plugins')
      hive
    end

    def update(*args)
      copy = ActionController::Parameters.new(args[0])
      args[0] = copy.permit(:hostname)
      %i[runner_version_history runner_plugin_version_history].each do |key|
        args[0][key] = copy[key] if copy.key?(key)
      end

      update_version(copy['version']) if copy.key?('version')
      update_runner_plugins(copy['runner_plugins']) if copy.key?('runner_plugins')
      super(*args)
    end

    def name
      hostname
    end

    def version
      history = runner_version_history.where(end_timestamp: nil).order(start_timestamp: :desc)
      !history.empty? ? history.first.runner_version.version : nil
    end

    def update_version(version)
      if version != self.version
        unless runner_version_history.empty?
          runner_version_history.last.end_timestamp = Time.now
        end
        runner_version_history << RunnerVersionHistory.create(
          runner_version: RunnerVersion.find_or_create_by(version: version),
          start_timestamp: Time.now
        )
      end
    end

    def runner_plugins
      Hash[runner_plugin_version_history.where(end_timestamp: nil).map { |h| [h.runner_plugin_version.name, h.runner_plugin_version.version] }]
    end

    def update_runner_plugins(plugins = {})
      runner_plugin_version_history.select { |h| h.end_timestamp.nil? }.each do |h|
        if plugins.key?(h.runner_plugin_version.name) && plugins[h.runner_plugin_version.name] == h.runner_plugin_version.version
          plugins.delete(h.runner_plugin_version.name)
        else
          h.end_timestamp = Time.now
          h.save
        end
      end

      plugins.each_pair do |p, v|
        runner_plugin_version_history << RunnerPluginVersionHistory.create(
          runner_plugin_version: RunnerPluginVersion.find_or_create_by(
            name: p,
            version: v
          ),
          start_timestamp: Time.now
        )
      end
    end

    def details
      {
        'version' => version,
        'runner_plugins' => runner_plugins
      }
    end

    def json_keys
      %i[version connected_devices]
    end

    def connect(device)
      if (h = Plugin.find_by_connected_device(device)) && (h != self)
        h.plugin.disconnect device
      end
      self.device.add_relation 'connected', device
    end

    def disconnect(device)
      self.device.delete_relation 'connected', device
    end

    def connected_devices
      device.related_devices
    end

    def self.plugin_params(params)
      params.permit(:hostname, :version).merge(params.select { |key, _value| key.to_s.match(/^runner_plugins$/) })
    end

    def self.find_by_connected_device(device)
      if r = Relationship.where(secondary: device).first
        r.primary
      end
    end
  end
end
