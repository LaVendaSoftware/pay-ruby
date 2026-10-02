require "webmock/rspec"
require "lavenda_pay"

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.disable_monkey_patching!
  config.order = :random

  config.before do
    LavendaPay.reset_configuration!
    LavendaPay.configure do |c|
      c.base_url = "https://pay.example.com"
      c.api_token = "token-123"
      c.webhook_secret = "whsec"
    end
  end
end
