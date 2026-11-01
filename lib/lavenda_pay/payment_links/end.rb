module LavendaPay
  module PaymentLinks
    # Final: nobody can pay through the link anymore. Orders and payments it
    # generated stay as they are.
    #
    # LavendaPay::PaymentLinks::End.call("payment_link_...") # => LavendaPay::PaymentLink
    class End < Operation
      def call(pid)
        body = http.post("/v1/payment_links/#{escape(pid)}/ending")
        PaymentLink.new(body["payment_link"] || body)
      end
    end
  end
end
