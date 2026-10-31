module LavendaPay
  module PaymentLinks
    # LavendaPay::PaymentLinks::Find.call("payment_link_...") # => LavendaPay::PaymentLink
    class Find < Operation
      def call(pid)
        body = http.get("/v1/payment_links/#{escape(pid)}")
        PaymentLink.new(body["payment_link"] || body)
      end
    end
  end
end
