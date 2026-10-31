module LavendaPay
  class PaymentOption < Resource
    # Attributes: payment_method_kind ("pix" or "credit_card"), installment_count,
    # installment_value, total, fee, net_amount.
  end

  class PaymentSimulation < Resource
    # Attributes: amount, options.
    def options
      Array(self["options"]).map { |option| PaymentOption.new(option) }
    end
  end
end
