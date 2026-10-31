module LavendaPay
  class Order < Resource
    # Attributes: pid, status, expires_at, requires_billing_address,
    # payment_link_pid, card_installment_count, customer.
    def customer
      value = self["customer"]
      value.is_a?(Hash) ? Customer.new(value) : value
    end

    # The chosen installments as priced by the server when the order was created.
    def card_installment_option
      value = self["card_installment_option"]
      value && PaymentOption.new(value)
    end
  end
end
