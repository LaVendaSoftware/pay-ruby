module LavendaPay
  module Orders
    # LavendaPay::Orders::Find.call("order_...") # => LavendaPay::Order
    class Find < Operation
      def call(pid)
        body = http.get("/v1/orders/#{escape(pid)}")
        Order.new(body["order"] || body)
      end
    end
  end
end
