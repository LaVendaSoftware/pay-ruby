module LavendaPay
  module Payments
    # Record an actual receipt verified by the merchant. Works for pending and
    # canceled manual Pix, including in production. Retries return the original
    # receipt. Inspect payment.manual_pix_receipt["needs_review"] before treating
    # unapplied funds as settled; canceled/paid orders are never reopened.
    class ConfirmManualPix < Operation
      def call(pid)
        body = http.post("/v1/payments/#{escape(pid)}/manual_confirmation")
        Payment.new(body["payment"] || body)
      end
    end
  end
end
