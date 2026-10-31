module LavendaPay
  module PaymentLinks
    # LavendaPay::PaymentLinks::Create.call(
    #   name: "Mentoria", billing_type: "undefined", charge_type: "detached", amount: 150.0
    # ) # => LavendaPay::PaymentLink
    class Create < Operation
      def call(params)
        body = http.post("/v1/payment_links", body: {payment_link: params})
        PaymentLink.new(body["payment_link"] || body)
      end
    end
  end
end
