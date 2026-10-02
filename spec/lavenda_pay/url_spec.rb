RSpec.describe LavendaPay::Url do
  describe ".order_path" do
    it "builds the public order page from checkout_url" do
      LavendaPay.configuration.checkout_url = "https://loja.example.com/"

      expect(described_class.order_path("order_123")).to eq("https://loja.example.com/orders/order_123")
    end

    it "falls back to base_url" do
      expect(described_class.order_path("order_123")).to eq("https://pay.example.com/orders/order_123")
    end
  end
end
