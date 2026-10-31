module LavendaPay
  class PaymentLink < Resource
    # Attributes: pid, status, url, name, description, billing_type, charge_type,
    # amount, end_date, ended_at, due_date_limit_days, eid, success_url,
    # auto_redirect, requires_billing_address.
    #
    # `amount` is the offer's base price, nil when the payer types it. What a
    # payment charges depends on the payment method.
  end
end
