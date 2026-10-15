module LavendaPay
  module Orders
    # LavendaPay::Orders::Create.call(
    #   customer_pid: "...", payment_method_kinds: ["manual_pix"],
    #   description: "...", eid: "ORD-1",
    #   items_attributes: [{product_title: "...", quantity: 1, unit_price: 450.0}]
    # ) # => LavendaPay::Order
    # manual_pix requires an admin-enabled company with a configured fixed Pix key.
    class Create < Operation
      def call(params)
        body = http.post("/v1/orders", body: {order: params})
        Order.new(body["order"] || body)
      end
    end
  end
end
