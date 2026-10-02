RSpec.describe "LavendaPay::Orders" do
  describe LavendaPay::Orders::Create do
    let(:params) do
      {
        customer_pid: "cus_1", payment_method_kinds: ["pix"], frequency: "once", currency: "brl",
        items_attributes: [{product_title: "Livro", quantity: 1, unit_price: 450.0}]
      }
    end

    it "creates an order and unwraps the response" do
      stub = stub_request(:post, "https://pay.example.com/api/v1/orders")
        .with(body: {order: params}.to_json)
        .to_return(status: 201, body: {order: {pid: "order_1", status: "draft", requires_billing_address: true,
                                               customer: {pid: "cus_1"}}}.to_json)

      order = described_class.call(params)

      expect(stub).to have_been_requested
      expect([order.pid, order.status, order.requires_billing_address]).to eq(["order_1", "draft", true])
      expect(order.customer).to be_a(LavendaPay::Customer)
    end
  end

  describe LavendaPay::Orders::Find do
    it "finds an order by pid" do
      stub_request(:get, "https://pay.example.com/api/v1/orders/order_1")
        .to_return(status: 200, body: {order: {pid: "order_1", status: "paid"}}.to_json)

      expect(described_class.call("order_1").status).to eq("paid")
    end

    it "maps 401 to AuthenticationError and 500 to ServerError" do
      stub_request(:get, "https://pay.example.com/api/v1/orders/a").to_return(status: 401, body: "{}")
      stub_request(:get, "https://pay.example.com/api/v1/orders/b").to_return(status: 503, body: "boom")

      expect { described_class.call("a") }.to raise_error(LavendaPay::AuthenticationError)
      expect { described_class.call("b") }.to raise_error(LavendaPay::ServerError)
    end

    it "wraps network failures in ConnectionError" do
      stub_request(:get, "https://pay.example.com/api/v1/orders/a").to_timeout

      expect { described_class.call("a") }.to raise_error(LavendaPay::ConnectionError)
    end
  end
end
