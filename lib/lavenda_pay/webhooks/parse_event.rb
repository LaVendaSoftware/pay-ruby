module LavendaPay
  module Webhooks
    # LavendaPay::Webhooks::ParseEvent.call(request.raw_post) # => Event
    # Raises InvalidWebhookPayloadError for bad JSON or missing keys.
    class ParseEvent
      def self.call(payload) = Event.parse(payload)
    end
  end
end
