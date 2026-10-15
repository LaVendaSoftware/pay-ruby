module LavendaPay
  class Payment < Resource
    # Attributes: pid, status, and gateway_confirmation after a sandbox
    # confirmation ("confirmed", "failed" or "unsupported"). Manual Pix also
    # exposes manual_pix_receipt: received_at, original_status, received_amount_cents,
    # credited_amount_cents (gross order credit), unapplied_amount_cents (net funds),
    # needs_review, review_reason, confirmation_source and confirmed_by_reference.
  end
end
