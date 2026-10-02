RSpec.describe "LavendaPay::Customers" do
  let(:customer_json) { {pid: "cus_1", full_name: "Ana", user_email: "ana@example.com"} }

  describe LavendaPay::Customers::Create do
    it "posts the wrapped params with bearer auth and unwraps the customer" do
      stub = stub_request(:post, "https://pay.example.com/api/v1/customers")
        .with(
          headers: {"Authorization" => "Bearer token-123", "Content-Type" => "application/json"},
          body: {customer: {full_name: "Ana"}}.to_json
        )
        .to_return(status: 201, body: {customer: customer_json}.to_json)

      customer = described_class.call({full_name: "Ana"})

      expect(stub).to have_been_requested
      expect([customer.pid, customer.full_name]).to eq(["cus_1", "Ana"])
    end

    it "accepts keyword-style params too" do
      stub_request(:post, "https://pay.example.com/api/v1/customers")
        .with(body: {customer: {full_name: "Ana"}}.to_json)
        .to_return(status: 201, body: {customer: customer_json}.to_json)

      expect(described_class.call(full_name: "Ana").pid).to eq("cus_1")
    end

    it "raises UnprocessableError exposing the API errors" do
      stub_request(:post, "https://pay.example.com/api/v1/customers")
        .to_return(status: 422, body: {errors: {user_email: ["is invalid"]}}.to_json)

      expect { described_class.call({full_name: "Ana"}) }.to raise_error(LavendaPay::UnprocessableError) { |error|
        expect(error.status).to eq(422)
        expect(error.errors).to eq({"user_email" => ["is invalid"]})
      }
    end

    it "can run on an explicit client" do
      client = LavendaPay::Client.new(base_url: "https://other.example.com")
      stub = stub_request(:post, "https://other.example.com/api/v1/customers")
        .to_return(status: 201, body: {customer: customer_json}.to_json)

      described_class.new(client:).call({full_name: "Ana"})

      expect(stub).to have_been_requested
    end
  end

  describe LavendaPay::Customers::FindBy do
    it "filters by document_number and returns the first match" do
      stub_request(:get, "https://pay.example.com/api/v1/customers")
        .with(query: {document_number: "123"})
        .to_return(status: 200, body: {customers: [customer_json]}.to_json)

      expect(described_class.call(document_number: "123").pid).to eq("cus_1")
    end

    it "returns nil when nothing matches" do
      stub_request(:get, "https://pay.example.com/api/v1/customers")
        .with(query: {user_email: "x@example.com"})
        .to_return(status: 200, body: {customers: []}.to_json)

      expect(described_class.call(user_email: "x@example.com")).to be_nil
    end

    it "does not hit the API without a supported filter" do
      expect(described_class.call(full_name: "Ana", user_email: " ")).to be_nil
      expect(a_request(:any, /pay.example.com/)).not_to have_been_made
    end
  end

  describe LavendaPay::Customers::List do
    it "returns customers, ignoring unsupported filters" do
      stub = stub_request(:get, "https://pay.example.com/api/v1/customers")
        .with(query: {user_email: "ana@example.com", page: "2"})
        .to_return(status: 200, body: {customers: [customer_json]}.to_json)

      result = described_class.call(user_email: "ana@example.com", page: 2, full_name: "ignored")

      expect(stub).to have_been_requested
      expect(result.map(&:pid)).to eq(["cus_1"])
    end
  end

  describe LavendaPay::Customers::Find do
    it "unwraps the customer" do
      stub_request(:get, "https://pay.example.com/api/v1/customers/cus_1")
        .to_return(status: 200, body: {customer: customer_json}.to_json)

      expect(described_class.call("cus_1").user_email).to eq("ana@example.com")
    end

    it "raises NotFoundError on 404" do
      stub_request(:get, "https://pay.example.com/api/v1/customers/nope").to_return(status: 404, body: "{}")

      expect { described_class.call("nope") }.to raise_error(LavendaPay::NotFoundError)
    end
  end
end
