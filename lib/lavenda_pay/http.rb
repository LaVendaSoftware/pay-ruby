require "json"
require "net/http"
require "uri"

module LavendaPay
  # Minimal JSON-over-HTTP transport built on net/http.
  class HTTP
    ERROR_CLASSES = {
      400 => BadRequestError,
      401 => AuthenticationError,
      403 => AuthenticationError,
      404 => NotFoundError,
      422 => UnprocessableError
    }.freeze

    NETWORK_ERRORS = [
      SocketError, Timeout::Error, EOFError, IOError,
      Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EHOSTUNREACH, OpenSSL::SSL::SSLError
    ].freeze

    def initialize(configuration)
      @configuration = configuration
    end

    def get(path, params: {})
      request(Net::HTTP::Get, path, params:)
    end

    def post(path, body: nil)
      request(Net::HTTP::Post, path, body:)
    end

    private

    attr_reader :configuration

    def request(verb_class, path, params: {}, body: nil)
      configuration.validate!

      uri = build_uri(path, params)
      req = verb_class.new(uri, headers)
      req.body = JSON.generate(body) unless body.nil?

      response = perform(uri, req)
      handle(response)
    end

    def perform(uri, req)
      Net::HTTP.start(
        uri.host, uri.port,
        use_ssl: uri.scheme == "https",
        open_timeout: configuration.open_timeout,
        read_timeout: configuration.read_timeout
      ) { |http| http.request(req) }
    rescue *NETWORK_ERRORS => error
      raise ConnectionError, "#{error.class}: #{error.message}"
    end

    def handle(response)
      status = response.code.to_i
      parsed = parse(response.body)

      return parsed if (200..299).cover?(status)

      raise error_class(status).new(nil, status:, body: parsed)
    end

    def error_class(status)
      ERROR_CLASSES.fetch(status) { (500..599).cover?(status) ? ServerError : ApiError }
    end

    def parse(raw)
      return {} if raw.nil? || raw.strip.empty?

      JSON.parse(raw)
    rescue JSON::ParserError
      {}
    end

    def build_uri(path, params)
      uri = URI.parse("#{configuration.base_url.to_s.chomp("/")}/api#{path}")
      compact = params.reject { |_, value| value.nil? || value.to_s.empty? }
      uri.query = URI.encode_www_form(compact) unless compact.empty?
      uri
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "Authorization" => "Bearer #{configuration.api_token}"
      }
    end
  end
end
