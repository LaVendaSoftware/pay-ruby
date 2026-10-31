module LavendaPay
  class PaymentOption < Resource
    # Attributes: payment_method_kind ("pix" or "credit_card"), installment_count,
    # installment_value, total, fee, net_amount. On Pix, which passes nothing on,
    # fee and net_amount are nil: unknown, not zero.
  end

  class PaymentSimulation < Resource
    # Attributes: amount, options.
    def options
      Array(self["options"]).map { |option| PaymentOption.new(option) }
    end
  end
end
