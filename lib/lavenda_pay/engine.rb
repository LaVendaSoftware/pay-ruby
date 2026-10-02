require "rails/engine"

module LavendaPay
  # Mount it to get a webhook endpoint without writing a controller:
  #
  #   mount LavendaPay::Engine => "/webhooks/lavenda_pay"
  class Engine < ::Rails::Engine
    isolate_namespace LavendaPay
  end
end
