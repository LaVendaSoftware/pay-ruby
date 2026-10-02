RSpec.describe LavendaPay::Webhooks do
  let(:payload) do
    {event: "order_paid", resource_type: "Order", resource_pid: "order_1", data: {pid: "order_1", status: "paid"}}
  end

  describe LavendaPay::Webhooks::Signature do
    it "accepts the configured secret" do
      expect(described_class.valid?("whsec")).to be(true)
    end

    it "rejects wrong, blank or missing secrets" do
      expect([described_class.valid?("nope"), described_class.valid?(""), described_class.valid?(nil)])
        .to eq([false, false, false])
    end

    it "rejects everything when no secret is configured" do
      expect(described_class.valid?("x", secret: nil)).to be(false)
    end
  end

  describe LavendaPay::Webhooks::Event do
    it "parses a JSON string" do
      event = described_class.parse(payload.to_json)

      expect([event.name, event.resource_id, event.pid]).to eq(["order_paid", "order_1", "order_1"])
    end

    it "accepts the legacy resource_id key" do
      legacy = payload.except(:resource_pid).merge(resource_id: 123)

      expect(described_class.parse(legacy).resource_id).to eq("123")
    end

    it "classifies events and exposes the order" do
      event = described_class.parse(payload)

      expect([event.order?, event.payment?, event.supported?]).to eq([true, false, true])
      expect(event.order.status).to eq("paid")
      expect(event.idempotency_key).to eq("order_paid:Order:order_1")
    end

    it "flags unknown events as unsupported" do
      expect(described_class.parse(payload.merge(event: "weird")).supported?).to be(false)
    end

    it "raises on missing keys and invalid JSON" do
      expect { described_class.parse(payload.except(:data)) }
        .to raise_error(LavendaPay::InvalidWebhookPayloadError, /data/)
      expect { described_class.parse("{") }.to raise_error(LavendaPay::InvalidWebhookPayloadError, /invalid JSON/)
    end
  end

  describe LavendaPay::Webhooks::VerifySignature do
    it "returns true for the configured secret" do
      expect(described_class.call("whsec")).to be(true)
    end

    it "raises for a wrong secret" do
      expect { described_class.call("bad") }.to raise_error(LavendaPay::InvalidWebhookSignatureError)
    end
  end

  describe LavendaPay::Webhooks::ParseEvent do
    it "returns an event" do
      expect(described_class.call(payload.to_json).name).to eq("order_paid")
    end
  end

  describe LavendaPay::Webhooks::ConstructEvent do
    it "returns the event when the secret matches" do
      expect(described_class.call(payload.to_json, "whsec").name).to eq("order_paid")
    end

    it "raises before parsing when the secret is wrong" do
      expect { described_class.call("{", "bad") }.to raise_error(LavendaPay::InvalidWebhookSignatureError)
    end
  end
end
