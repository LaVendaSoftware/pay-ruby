module LavendaPay
  module Orders
    # LavendaPay::Orders::Create.call(
    #   customer_pid: "...", payment_method_kinds: ["pix", "credit_card"],
    #   description: "...", eid: "ORD-1", frequency: "once", currency: "brl",
    #   items_attributes: [{product_title: "...", quantity: 1, unit_price: 450.0}]
    # ) # => LavendaPay::Order
    class Create < Operation
      def call(params)
        body = http.post("/v1/orders", body: {order: params})
        Order.new(body["order"] || body)
      end
    end
  end
end
