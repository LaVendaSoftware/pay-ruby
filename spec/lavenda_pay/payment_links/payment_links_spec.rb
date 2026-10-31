RSpec.describe "LavendaPay::PaymentLinks" do
  describe LavendaPay::PaymentLinks::Create do
    let(:params) { {name: "Mentoria", billing_type: "undefined", charge_type: "detached", amount: 150.0} }

    it "creates a payment link and unwraps the response" do
      stub = stub_request(:post, "https://pay.example.com/api/v1/payment_links")
        .with(body: {payment_link: params}.to_json)
        .to_return(status: 200, body: {payment_link: {pid: "link_1", status: "active", url: "https://acme.example.com/payment_links/link_1"}}.to_json)

      payment_link = described_class.call(params)

      expect(stub).to have_been_requested
      expect(payment_link).to be_a(LavendaPay::PaymentLink)
      expect([payment_link.pid, payment_link.status, payment_link.url]).to eq(["link_1", "active", "https://acme.example.com/payment_links/link_1"])
    end
  end

  describe LavendaPay::PaymentLinks::Find do
    it "finds a payment link by pid" do
      stub_request(:get, "https://pay.example.com/api/v1/payment_links/link_1")
        .to_return(status: 200, body: {payment_link: {pid: "link_1", amount: nil}}.to_json)

      expect(described_class.call("link_1").pid).to eq("link_1")
    end

    it "maps 404 to NotFoundError" do
      stub_request(:get, "https://pay.example.com/api/v1/payment_links/other").to_return(status: 404, body: "{}")

      expect { described_class.call("other") }.to raise_error(LavendaPay::NotFoundError)
    end
  end

  describe LavendaPay::PaymentLinks::List do
    it "sends only the supported filters and wraps each link" do
      stub = stub_request(:get, "https://pay.example.com/api/v1/payment_links")
        .with(query: {name: "Mentoria", page: "2"})
        .to_return(status: 200, body: {payment_links: [{pid: "link_1"}]}.to_json)

      payment_links = described_class.call(name: "Mentoria", page: 2, status: "ended")

      expect(stub).to have_been_requested
      expect(payment_links.map(&:pid)).to eq(["link_1"])
    end
  end

  describe LavendaPay::PaymentLinks::End do
    it "ends a payment link" do
      stub_request(:post, "https://pay.example.com/api/v1/payment_links/link_1/ending")
        .to_return(status: 200, body: {payment_link: {pid: "link_1", status: "ended"}}.to_json)

      expect(described_class.call("link_1").status).to eq("ended")
    end
  end
end
