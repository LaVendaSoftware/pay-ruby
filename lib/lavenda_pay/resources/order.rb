module LavendaPay
  class Order < Resource
    # Attributes: pid, status, expires_at, requires_billing_address, customer.
    def customer
      value = self["customer"]
      value.is_a?(Hash) ? Customer.new(value) : value
    end
  end
end
