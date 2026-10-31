RSpec.describe "LavendaPay::Payments" do
  describe LavendaPay::Payments::Simulate do
    let(:url) { "https://pay.example.com/api/v1/payment_simulations" }

    it "simulates an amount and exposes the options" do
      stub = stub_request(:post, url)
        .with(body: {payment_simulation: {amount: 100.0}}.to_json)
        .to_return(status: 200, body: {payment_simulation: {amount: 100.0, options: [
          {payment_method_kind: "pix", installment_count: 1, installment_value: 100.99, total: 100.99, fee: 0.99, net_amount: 100.0},
          {payment_method_kind: "credit_card", installment_count: 3, installment_value: 34.18, total: 102.54, fee: 2.54, net_amount: 100.0}
        ]}}.to_json)

      simulation = described_class.call(amount: 100.0)

      expect(stub).to have_been_requested
      expect(simulation).to be_a(LavendaPay::PaymentSimulation)
      expect(simulation.amount).to eq(100.0)
      expect(simulation.options.map(&:payment_method_kind)).to eq(["pix", "credit_card"])
      expect(simulation.options.last).to be_a(LavendaPay::PaymentOption)
      expect(simulation.options.last.total).to eq(102.54)
    end

    it "maps an invalid amount to UnprocessableError" do
      stub_request(:post, url).to_return(status: 422, body: {errors: {amount: ["inválido"]}}.to_json)

      expect { described_class.call(amount: 1) }.to raise_error(LavendaPay::UnprocessableError)
    end
  end

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
