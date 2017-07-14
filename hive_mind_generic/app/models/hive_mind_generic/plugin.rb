module HiveMindGeneric
  class Plugin < ActiveRecord::Base
    has_one :device, as: :plugin
    has_many :characteristics

    def name
      "Generic Device #{id}"
    end

    def details
      Hash[characteristics.map { |c| [c.key, c.value] }]
    end

    def update(*args)
      super *HiveMindGeneric::Plugin.extract_characteristics(args)
    end

    def self.plugin_params(params)
      params
    end

    def self.create(*args)
      super *extract_characteristics(args)
    end

    private

    def self.extract_characteristics(a = nil)
      if a[0]
        a[0] = {
          characteristics: a[0].keys.map do |k|
            Characteristic.new(key: k, value: a[0][k])
          end
        }
      end
      a
    end
  end
end
