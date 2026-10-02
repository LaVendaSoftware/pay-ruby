module LavendaPay
  module Customers
    # LavendaPay::Customers::Find.call("cus_...") # => LavendaPay::Customer
    class Find < Operation
      def call(pid)
        body = http.get("/v1/customers/#{escape(pid)}")
        Customer.new(body["customer"] || body)
      end
    end
  end
end
