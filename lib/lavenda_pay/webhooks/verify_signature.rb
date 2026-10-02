module LavendaPay
  module Webhooks
    # LavendaPay::Webhooks::VerifySignature.call(request.headers[Signature::HEADER])
    # # => true, or raises InvalidWebhookSignatureError
    class VerifySignature
      def self.call(received, secret: LavendaPay.configuration.webhook_secret)
        return true if Signature.valid?(received, secret:)

        raise InvalidWebhookSignatureError, "invalid webhook secret"
      end
    end
  end
end
