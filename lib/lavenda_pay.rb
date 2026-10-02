require_relative "lavenda_pay/version"
require_relative "lavenda_pay/errors"
require_relative "lavenda_pay/configuration"
require_relative "lavenda_pay/http"
require_relative "lavenda_pay/resource"
require_relative "lavenda_pay/resources/customer"
require_relative "lavenda_pay/resources/order"
require_relative "lavenda_pay/client"
require_relative "lavenda_pay/operation"
require_relative "lavenda_pay/customers/create"
require_relative "lavenda_pay/customers/find"
require_relative "lavenda_pay/customers/list"
require_relative "lavenda_pay/customers/find_by"
require_relative "lavenda_pay/orders/create"
require_relative "lavenda_pay/orders/find"
require_relative "lavenda_pay/url"
require_relative "lavenda_pay/webhooks"
require_relative "lavenda_pay/engine" if defined?(Rails::Engine)

module LavendaPay
  class << self
    def configuration = @configuration ||= Configuration.new

    def configure
      yield configuration
      configuration
    end

    def reset_configuration! = @configuration = nil

    # Client bound to the global configuration.
    def client = Client.new
  end
end
