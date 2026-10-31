module LavendaPay
  module PaymentLinks
    FILTER_KEYS = %i[name eid].freeze

    # LavendaPay::PaymentLinks::List.call(name: "Mentoria", page: 1)
    # # => [LavendaPay::PaymentLink, ...]
    class List < Operation
      def call(page: nil, **filters)
        body = http.get("/v1/payment_links", params: {page:}.merge(filters.slice(*FILTER_KEYS)))
        Array(body["payment_links"]).map { |attributes| PaymentLink.new(attributes) }
      end
    end
  end
end
