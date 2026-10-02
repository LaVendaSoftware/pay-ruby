RSpec.describe LavendaPay::Configuration do
  it "falls back to environment variables" do
    stub_const("ENV", ENV.to_h.merge("LAVENDA_PAY_BASE_URL" => "https://env.example.com"))

    expect(described_class.new.base_url).to eq("https://env.example.com")
  end

  it "fails fast when the client is not configured" do
    LavendaPay.reset_configuration!
    stub_const("ENV", {})

    expect { LavendaPay::Orders::Find.call("x") }.to raise_error(LavendaPay::ConfigurationError, /base_url/)
  end

  it "lets a client override the global configuration" do
    client = LavendaPay::Client.new(base_url: "https://other.example.com")
    stub = stub_request(:get, "https://other.example.com/api/v1/orders/o").to_return(status: 200, body: "{}")

    LavendaPay::Orders::Find.new(client:).call("o")

    expect(stub).to have_been_requested
  end
end
