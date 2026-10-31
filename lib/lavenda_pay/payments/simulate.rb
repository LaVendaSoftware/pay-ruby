module LavendaPay
  module Payments
    # Simulates the amount the merchant wants to receive, with every fee passed
    # on to the customer. It is a preview at the current rates: send the chosen
    # card count as `card_installment_count` to LavendaPay::Orders::Create, and
    # the server computes the amount again.
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
