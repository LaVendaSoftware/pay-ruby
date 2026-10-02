RSpec.describe LavendaPay::Configuration do
  it "falls back to environment variables" do
    stub_const("ENV", ENV.to_h.merge("LAVENDA_PAY_BASE_URL" => "https://env.example.com"))

    expect(described_class.new.base_url).to eq("https://env.example.com")
  end

  it "falls back to the lavenda_pay Rails credentials" do
    stub_const("ENV", {})
    credentials = double
    allow(credentials).to receive(:dig).with(:lavenda_pay, :api_token).and_return("credential-token")
    application = double(credentials:)
    stub_const("Rails", Module.new)
    Rails.define_singleton_method(:application) { application }

    expect(described_class.new.api_token).to eq("credential-token")
  end

  it "prefers the environment over the Rails credentials" do
    stub_const("ENV", {"LAVENDA_PAY_API_TOKEN" => "env-token"})
    stub_const("Rails", Module.new)
    Rails.define_singleton_method(:application) { raise "credentials should not be read" }

    expect(described_class.new.api_token).to eq("env-token")
  end

  it "uses base_url as checkout_url unless set" do
    stub_const("ENV", {})
    config = described_class.new
    config.base_url = "https://pay.example.com"

    expect(config.checkout_url).to eq("https://pay.example.com")

    config.checkout_url = "https://loja.example.com"

    expect(config.checkout_url).to eq("https://loja.example.com")
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
