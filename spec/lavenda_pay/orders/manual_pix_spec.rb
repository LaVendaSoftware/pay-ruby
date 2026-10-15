RSpec.describe LavendaPay::Orders::Create do
  it "sends the manual Pix method unchanged" do
    stub_request(:post, "https://pay.example.com/api/v1/orders")
      .with(body: {order: {payment_method_kinds: ["manual_pix"]}}.to_json)
      .to_return(status: 200, body: {order: {pid: "order_1", status: "pending"}}.to_json)

    expect(described_class.call(payment_method_kinds: ["manual_pix"]).pid).to eq("order_1")
  end
end
