module LavendaPay
  module Payments
    # Sandbox only: marks a pending payment as paid, and confirms it on the
    # gateway when the gateway supports it. Production answers 404 (NotFoundError).
    #
    # LavendaPay::Payments::Confirm.call("pay_...") # => LavendaPay::Payment
    class Confirm < Operation
      def call(pid)
        body = http.post("/v1/payments/#{escape(pid)}/confirmation")
        gateway_confirmation = body.dig("meta", "gateway_confirmation")

        Payment.new((body["payment"] || body).merge("gateway_confirmation" => gateway_confirmation))
      end
    end
  end
end
