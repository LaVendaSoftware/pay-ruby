require "rails"
require "action_controller/railtie"
require "lavenda_pay/engine"

class LavendaPayTestApp < Rails::Application
  config.eager_load = false
  config.secret_key_base = "test"
  config.logger = Logger.new(nil)
  config.hosts.clear
  config.action_dispatch.show_exceptions = :none
end

LavendaPayTestApp.initialize!
LavendaPayTestApp.routes.draw { mount LavendaPay::Engine => "/webhooks/lavenda_pay" }
