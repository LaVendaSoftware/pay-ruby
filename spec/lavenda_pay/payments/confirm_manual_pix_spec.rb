RSpec.describe LavendaPay::Payments::ConfirmManualPix do
  let(:receipt) do
    {"received_amount_cents" => 900, "credited_amount_cents" => 1000,
     "unapplied_amount_cents" => 0, "needs_review" => false, "original_status" => "pending"}
  end

  it "returns the manual receipt and escapes the public payment identifier" do
    stub_request(:post, "https://pay.example.com/api/v1/payments/pay%2F1/manual_confirmation")
      .to_return(status: 200, body: {payment: {pid: "pay/1", status: "paid", manual_pix_receipt: receipt}}.to_json)

    payment = described_class.call("pay/1")
    expect(payment).to be_a(LavendaPay::Payment)
    expect(payment.manual_pix_receipt).to eq(receipt)
  end

  it "preserves review-only canceled receipts without claiming settlement" do
    receipt.merge!("needs_review" => true, "credited_amount_cents" => 0, "unapplied_amount_cents" => 900)
    stub_request(:post, "https://pay.example.com/api/v1/payments/pay_1/manual_confirmation")
      .to_return(status: 200, body: {payment: {pid: "pay_1", status: "canceled", manual_pix_receipt: receipt}}.to_json)

    expect(described_class.call("pay_1").manual_pix_receipt["needs_review"]).to be(true)
  end

  it "maps an invalid confirmation to UnprocessableError" do
    stub_request(:post, "https://pay.example.com/api/v1/payments/pay_1/manual_confirmation")
      .to_return(status: 422, body: {errors: {base: ["Unavailable"]}}.to_json)
    expect { described_class.call("pay_1") }.to raise_error(LavendaPay::UnprocessableError)
  end

  it "maps a payment from another company to NotFoundError" do
    stub_request(:post, "https://pay.example.com/api/v1/payments/pay_1/manual_confirmation").to_return(status: 404)
    expect { described_class.call("pay_1") }.to raise_error(LavendaPay::NotFoundError)
  end
end
