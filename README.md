# Hive Mind

For a full list of release notes, see the [change log](CHANGELOG.md)

## Device Engines

For a device called 'mydevice' create a device engine with:

```bash
rails plugin new hive_mind_mydevice --full --dummy-path=spec/dummy
cd hive_mind_mydevice
```

**Optional:** To use rspec for unit tests see the section below.

Ensure that the tables created for the engine are correctly namespaced
and make the migrations visible to the application by
editing `lib/hive_mind_mydevice/engine.rb`:

```ruby
module HiveMindMydevice
  class Engine < ::Rails::Engine
    isolate_namespace HiveMindMydevice

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end
  end
end
```

Create a new model `Plugin` with relevant attributes:

```bash
rails generate model plugin <attributes>
```

Modify the `app/model/hive_mind_mydevice/plugin.rb` model:

```ruby
module HiveMindMydevice
  class Plugin < ActiveRecord::Base

    has_one :device, as: :plugin

    def name
      # Method for creating the devices name
      # Required
    end

    def json_keys
      # Return array of keys to include in the api/devices/:id endpoint
      # Optional
    end

    def self.plugin_params params
      # Return valid parameters from the input list. For example,
      params.permit(:attribute_one, attribute_two)
    end
  end
end
```

To include engine specific javascript create a file
`app/assets/javascripts/hive_mind_mydevice.js` containing

```ruby
//= require_tree './hive_mind_mydevice'
```

and add the following lines to `lib/hive_mind_mydevice/engine.rb` inside
the `Engine` class:

```ruby
    initializer :assets do |app|
      app.config.assets.precompile += %w( hive_mind_mydevice.js )
    end
```

Now all the custom javascript files for the engine can be put in the directory
`app/assets/javascripts/hive_mind_mydevice`.

### Using rspec to with engines

To use rspec for unit tests add `--skip-test-unit` to the
`rails plugin new` command so that it is:

```bash
rails plugin new hive_mind_mydevice --full --dummy-path=spec/dummy --skip-test-unit
```

Then add the following line to the file `hive_mind_mydevice.gemspec`:

```ruby
s.add_development_dependency 'rspec-rails'
```

Edit the `lib/hive_mind_mydevice/engine.rb` file to include rspec:

```ruby
module HiveMindMydevice
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
```

Set up rspec with:

```bash
bundle install
rails generate rspec:install
```

Finally, edit the `spec/rails_helper.rb` file to find the environment for the
dummy Rails:

```ruby
require File.expand_path('../dummy/config/environment', __FILE__)
```

## Run as production

Edit the file `config/database.yml` to specify the correct database
credentials. Set up the assets:

```bash
RAILS_ENV=production rake assets:precompile`
```

Then run the server as:

```bash
RAILS_ENV=production SECRET_KEY_BASE=YourSecret rails s -b 0.0.0.0
```

## Testing

To execute the integration tests run:

```bash
RAILS_ENV=integration rspec spec_integration
```

Note that you may need to edit `Gemfile` to include the correct version of the
plugin being tested.

## API

Action | Method | Endpoint
-------|--------|---------
View device | GET | `api/devices/*id*`
Register device | POST | `api/devices/register`
Poll device | PUT | `api/devices/poll`
Add device action | PUT | `api/devices/action`
Connect device | PUT | `api/plugin/hive/connect`
Disconnect device | PUT | `api/plugin/hive/disconnect`
Upload statistical data | POST | `api/device_statistics/upload`

### View device

### Register device

```json
{
  "device": {
    "name": "Device name",
    "model": "Device model",
    "brand": "Device brand",
    "ips": [ "10.10.10.1", "192.168.99.99" ],
    "macs": [ "aa:bb:cc:dd:ee:ff", "01:23:45:67:89:AB" ],
    "device_type": "Device plugin"
  }
}
```

All parameters are optional although the `name` is required unless the
`device_type` parameter is specified for a known Hive Mind plugin that
provides a `name` method.

### Poll device

To poll a single device:

```json
{
  "poll": {
    "id": 99
  }
}
```

To poll multiple devices:

```json
{
  "poll": {
    "id": 99,
    "devices": [ 1, 2, 3, 4 ]
  }
}
```

### Add device action

```json
{
  "device_action": {
    "device_id": 99,
    "action_type": "Type of action",
    "body": "Body of the action"
  }
}
```

### Upload statistical data

```json
{
  "data": [
    {
      "device_id": 99,
      "timestamp": "Timestamp for data value",
      "label": "Label for data value",
      "value": 123.456
      "format": "integer" or "float"
    },
    ...
  ]
}
```

### Connect device (Hive plugin)

```json
{
  "connection": {
    "hive_id": 3,
    "device_id": 6
  }
}
```

### Disconnect device (Hive plugin)

```json
{
  "connection": {
    "hive_id": 3,
    "device_id": 6
  }
}
```

## License

Hive Mind is available to everyone under the terms of the MIT open source licence.
Take a look at the LICENSE file in the code.

Copyright (c) 2015 BBC
