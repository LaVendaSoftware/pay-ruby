RSpec.describe "LavendaPay::Payments" do
  describe LavendaPay::Payments::Confirm do
    it "confirms a payment and exposes the gateway confirmation" do
      stub = stub_request(:post, "https://pay.example.com/api/v1/payments/pay_1/confirmation")
        .to_return(status: 200, body: {payment: {pid: "pay_1", status: "paid"},
                                       meta: {gateway_confirmation: "confirmed"}}.to_json)

      payment = described_class.call("pay_1")

      expect(stub).to have_been_requested
      expect(payment).to be_a(LavendaPay::Payment)
      expect([payment.pid, payment.status, payment.gateway_confirmation]).to eq(["pay_1", "paid", "confirmed"])
    end

    it "maps a non-confirmable payment to UnprocessableError" do
      stub_request(:post, "https://pay.example.com/api/v1/payments/pay_1/confirmation")
        .to_return(status: 422, body: {errors: {status: ["não pode ser confirmado (Pago)"]}}.to_json)

      expect { described_class.call("pay_1") }.to raise_error(LavendaPay::UnprocessableError)
    end

    it "maps production, where the route does not exist, to NotFoundError" do
      stub_request(:post, "https://pay.example.com/api/v1/payments/pay_1/confirmation").to_return(status: 404, body: "")

      expect { described_class.call("pay_1") }.to raise_error(LavendaPay::NotFoundError)
    end
  end
end
