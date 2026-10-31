module LavendaPay
  class Payment < Resource
    # Attributes: pid, status, installment_count, surcharge (the fees passed on
    # to the customer), charged_total, and gateway_confirmation after a sandbox
    # confirmation ("confirmed", "failed" or "unsupported").
  end
end
