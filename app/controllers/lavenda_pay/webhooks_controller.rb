module LavendaPay
  class WebhooksController < ActionController::API
    def create
      event = Webhooks::ConstructEvent.call(
        request.raw_post,
        request.headers[Webhooks::Signature::HEADER]
      )

      handle(event) if event.supported?

      head :ok
    rescue InvalidWebhookSignatureError
      head :unauthorized
    rescue InvalidWebhookPayloadError
      head :unprocessable_entity
    end

    private

    # Errors raised by the handler are not rescued on purpose: the request
    # fails with 500 so the sender retries the delivery.
    def handle(event)
      handler = LavendaPay.configuration.on_event
      raise ConfigurationError, "LavendaPay on_event handler is not configured" if handler.nil?

      handler.call(event)
    end
  end
end
