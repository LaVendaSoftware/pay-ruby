require "rack/test"
require_relative "../support/rails_app"

RSpec.describe "LavendaPay::Engine webhooks" do
  include Rack::Test::Methods

  def app = LavendaPayTestApp

  let(:received) { [] }
  let(:payload) do
    {event: "order_paid", resource_type: "Order", resource_pid: "order_1", data: {pid: "order_1", status: "paid"}}
  end
  let(:secret) { "whsec" }

  before { LavendaPay.configuration.on_event = ->(event) { received << event } }

  def deliver(body = payload.to_json, secret: self.secret)
    header "Content-Type", "application/json"
    header LavendaPay::Webhooks::Signature::HEADER, secret if secret
    post "/webhooks/lavenda_pay", body
  end

  it "passes a verified event to the handler and responds 200" do
    deliver

    expect(last_response.status).to eq(200)
    expect(received.map(&:name)).to eq(["order_paid"])
  end

  it "responds 401 without calling the handler when the secret is wrong or missing" do
    deliver(secret: "bad")
    expect(last_response.status).to eq(401)

    deliver(secret: nil)
    expect(last_response.status).to eq(401)
    expect(received).to be_empty
  end

  it "responds 422 for an invalid payload" do
    deliver("{")

    expect(last_response.status).to eq(422)
    expect(received).to be_empty
  end

  it "responds 200 without calling the handler for unsupported events" do
    deliver(payload.merge(event: "weird").to_json)

    expect(last_response.status).to eq(200)
    expect(received).to be_empty
  end

  it "lets handler errors surface so the sender retries" do
    LavendaPay.configuration.on_event = ->(_event) { raise "boom" }

    expect { deliver }.to raise_error("boom")
  end

  it "fails with a configuration error when no handler is set" do
    LavendaPay.configuration.on_event = nil

    expect { deliver }.to raise_error(LavendaPay::ConfigurationError, /on_event/)
  end
end
