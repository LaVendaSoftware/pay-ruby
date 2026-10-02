module LavendaPay
  class Configuration
    DEFAULT_TIMEOUT = 30

    attr_writer :base_url, :api_token, :webhook_secret
    attr_accessor :open_timeout, :read_timeout, :logger

    # Callable receiving a LavendaPay::Webhooks::Event; used by the mounted engine.
    attr_accessor :on_event

    def initialize
      @open_timeout = DEFAULT_TIMEOUT
      @read_timeout = DEFAULT_TIMEOUT
    end

    # Root URL of the Lavenda Pay installation, without the `/api` suffix.
    def base_url = @base_url || ENV["LAVENDA_PAY_BASE_URL"]

    def api_token = @api_token || ENV["LAVENDA_PAY_API_TOKEN"]

    def webhook_secret = @webhook_secret || ENV["LAVENDA_PAY_WEBHOOK_SECRET"]

    def validate!
      raise ConfigurationError, "LavendaPay base_url is not configured (LAVENDA_PAY_BASE_URL)" if blank?(base_url)
      raise ConfigurationError, "LavendaPay api_token is not configured (LAVENDA_PAY_API_TOKEN)" if blank?(api_token)

      self
    end

    private

    def blank?(value) = value.nil? || value.to_s.strip.empty?
  end
end
