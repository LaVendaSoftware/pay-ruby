module LavendaPay
  module Customers
    # Query keys the API filters on. Any other key is ignored server-side and
    # the API would return *every* customer, so we never send them.
    FILTER_KEYS = %i[user_email document_number].freeze

    # LavendaPay::Customers::List.call(user_email: "...", page: 1)
    # # => [LavendaPay::Customer, ...]
    class List < Operation
      def call(page: nil, **filters)
        body = http.get("/v1/customers", params: {page:}.merge(filters.slice(*FILTER_KEYS)))
        Array(body["customers"]).map { |attributes| Customer.new(attributes) }
      end
    end
  end
end
