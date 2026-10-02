require "openssl"

module LavendaPay
  module Webhooks
    # Lavenda Pay authenticates deliveries with a shared secret sent in the
    # webhook secret header (see HEADER).
    module Signature
      HEADER = "X-Lavenda-Pay-Webhook-Secret".freeze

      module_function

      def valid?(received, secret: LavendaPay.configuration.webhook_secret)
        return false if received.nil? || received.empty? || secret.nil? || secret.empty?

        # Hash both sides so the comparison is constant-time regardless of length.
        OpenSSL.fixed_length_secure_compare(digest(received), digest(secret))
      end

      def digest(value) = OpenSSL::Digest::SHA256.digest(value.to_s)
    end
  end
end
