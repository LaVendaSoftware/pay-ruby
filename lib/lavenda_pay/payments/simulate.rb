module LavendaPay
  module Payments
    # Previews the options for the amount the merchant wants to receive: one per
    # credit card installment count, with the card fee passed on to the customer,
    # and one for Pix at the plain amount. It binds no price: the customer chooses
    # the installments on the order's payment page, where the amount is computed
    # again.
    #
    # LavendaPay::Payments::Simulate.call(amount: 100.0) # => LavendaPay::PaymentSimulation
    class Simulate < Operation
      def call(amount:)
        body = http.post("/v1/payment_simulations", body: {payment_simulation: {amount: amount}})

        PaymentSimulation.new(body["payment_simulation"] || body)
      end
    end
  end
end
