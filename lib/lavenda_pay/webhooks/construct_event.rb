module LavendaPay
  module Webhooks
    # Checks the secret header, then parses the raw body. For controllers:
    #
    #   event = LavendaPay::Webhooks::ConstructEvent.call(
    #     request.raw_post, request.headers[LavendaPay::Webhooks::Signature::HEADER]
    #   )
    class ConstructEvent
      def self.call(raw_body, received_secret, secret: LavendaPay.configuration.webhook_secret)
        VerifySignature.call(received_secret, secret:)
        ParseEvent.call(raw_body)
      end
    end
  end
end
