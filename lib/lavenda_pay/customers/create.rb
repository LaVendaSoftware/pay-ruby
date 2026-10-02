module LavendaPay
  module Customers
    # LavendaPay::Customers::Create.call(
    #   full_name: "...", user_email: "...", document_type: "cpf",
    #   document_number: "...", dial_code: "55", phone_number: "...", eid: "..."
    # ) # => LavendaPay::Customer
    class Create < Operation
      def call(params)
        body = http.post("/v1/customers", body: {customer: params})
        Customer.new(body["customer"] || body)
      end
    end
  end
end
