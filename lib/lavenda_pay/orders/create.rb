module LavendaPay
  module Orders
    # LavendaPay::Orders::Create.call(
    #   customer_pid: "...", payment_method_kinds: ["pix", "credit_card"],
    #   description: "...", eid: "ORD-1", frequency: "once", currency: "brl",
    #   items_attributes: [{product_title: "...", quantity: 1, unit_price: 450.0}],
    #   card_installment_count: 3 # optional, from LavendaPay::Payments::Simulate
    # ) # => LavendaPay::Order
    class Create < Operation
      def call(params)
        body = http.post("/v1/orders", body: {order: params})
        option = body.dig("meta", "card_installment_option")
        order = body["order"] || body

        Order.new(option ? order.merge("card_installment_option" => option) : order)
      end
    end
  end
end
