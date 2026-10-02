module LavendaPay
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class ConnectionError < Error; end

  # Raised when the API answers with a non-2xx status.
  class ApiError < Error
    attr_reader :status, :body

    def initialize(message = nil, status: nil, body: nil)
      @status = status
      @body = body.is_a?(Hash) ? body : {}
      super(message || "Lavenda Pay API responded with #{status}")
    end

    # Errors as returned by the API (`{"errors" => ...}` or `{"error" => ...}`).
    def errors
      [body["errors"], body["error"]].find { |value| value && !value.empty? } || []
    end
  end

  class BadRequestError < ApiError; end

  class AuthenticationError < ApiError; end

  class NotFoundError < ApiError; end

  class UnprocessableError < ApiError; end

  class ServerError < ApiError; end

  class InvalidWebhookSignatureError < Error; end

  class InvalidWebhookPayloadError < Error; end
end
