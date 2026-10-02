RSpec.describe LavendaPay::Url do
  describe ".order_path" do
    it "builds the public order page from base_url" do
      LavendaPay.configuration.base_url = "https://pay.example.com/"

      expect(described_class.order_path("order_123")).to eq("https://pay.example.com/orders/order_123")
    end
  end
end
