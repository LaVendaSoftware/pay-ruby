module LavendaPay
  module Customers
    # First customer matching the filters, or nil. Returns nil (without hitting
    # the API) when no supported filter is given.
    #
    # LavendaPay::Customers::FindBy.call(document_number: "...")
    class FindBy < Operation
      def call(**filters)
        filters = filters.slice(*FILTER_KEYS).reject { |_, value| value.nil? || value.to_s.strip.empty? }
        return if filters.empty?

        List.new(client: client).call(**filters).first
      end
    end
  end
end
