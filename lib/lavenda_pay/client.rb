module LavendaPay
  # Holds a configuration and the HTTP transport. Pass it to an operation to
  # talk to a different account than the global one:
  #
  #   client = LavendaPay::Client.new(base_url: "...", api_token: "...")
  #   LavendaPay::Orders::Find.new(client: client).call("order_...")
  class Client
    attr_reader :configuration

    # Uses the global configuration unless options override it.
    def initialize(**options)
      @configuration = build_configuration(options)
    end

    def http = @http ||= HTTP.new(configuration)

    private

    def build_configuration(options)
      return LavendaPay.configuration if options.empty?

      base = LavendaPay.configuration
      Configuration.new.tap do |config|
        config.base_url = options.fetch(:base_url, base.base_url)
        config.api_token = options.fetch(:api_token, base.api_token)
        config.webhook_secret = options.fetch(:webhook_secret, base.webhook_secret)
        config.open_timeout = options.fetch(:open_timeout, base.open_timeout)
        config.read_timeout = options.fetch(:read_timeout, base.read_timeout)
      end
    end
  end
end
