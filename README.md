# Lavenda Pay Ruby

Ruby client for the [Lavenda Pay](https://github.com/LaVendaSoftware/pay-ruby) payments API.
Framework-agnostic (no Rails/ActiveSupport dependency): create customers and orders, and verify/parse webhooks.

## Installation

```ruby
gem "lavenda_pay", github: "LaVendaSoftware/pay-ruby"
```

## Configuration

```ruby
# config/initializers/lavenda_pay.rb
LavendaPay.configure do |config|
  config.base_url = ENV.fetch("LAVENDA_PAY_BASE_URL", Rails.application.credentials.dig(:lavenda_pay, :base_url))
  config.api_token = ENV.fetch("LAVENDA_PAY_API_TOKEN", Rails.application.credentials.dig(:lavenda_pay, :api_token))
  config.webhook_secret = ENV.fetch("LAVENDA_PAY_WEBHOOK_SECRET", Rails.application.credentials.dig(:lavenda_pay, :webhook_secret))
end
```

`base_url` is the root of the Lavenda Pay installation, without the `/api` suffix.

Outside Rails, set the values directly. Anything left unset falls back to the `LAVENDA_PAY_BASE_URL`,
`LAVENDA_PAY_API_TOKEN` and `LAVENDA_PAY_WEBHOOK_SECRET` environment variables.

Every operation is a class with `.call` that uses this global configuration. For several accounts, build a client and
pass it to the operation:

```ruby
client = LavendaPay::Client.new(base_url: "...", api_token: "...")
LavendaPay::Orders::Find.new(client:).call("order_...")
```

## Customers

```ruby
customer = LavendaPay::Customers::Create.call(
  full_name: "Pedro Henrique", user_email: "pedro@example.com",
  document_type: "cpf", document_number: "71415355436",
  dial_code: "55", phone_number: "(49) 98726-1668", eid: "TUTOR-1"
)
customer.pid # => "cus_..."

# Only `user_email` and `document_number` are supported filters (the API ignores
# anything else and would return every customer); returns nil when none match.
LavendaPay::Customers::FindBy.call(document_number: "71415355436") ||
  LavendaPay::Customers::FindBy.call(user_email: "pedro@example.com")

LavendaPay::Customers::Find.call("cus_...")
LavendaPay::Customers::List.call(user_email: "pedro@example.com", page: 1)
```

## Orders

```ruby
order = LavendaPay::Orders::Create.call(
  customer_pid: customer.pid,
  payment_method_kinds: ["pix", "credit_card"],
  description: "Material didático",
  eid: "ORD-0123",
  frequency: "once",
  currency: "brl",
  items_attributes: [{product_title: "Material didático", quantity: 1, unit_price: 450.0}]
)
order.pid    # => "order_..."
order.status # => "draft"

LavendaPay::Orders::Find.call(order.pid)
```

## Errors

Non-2xx responses raise a `LavendaPay::ApiError` subclass exposing `status`, `body` and `errors`:
`BadRequestError` (400), `AuthenticationError` (401/403), `NotFoundError` (404), `UnprocessableError` (422),
`ServerError` (5xx). Network failures raise `ConnectionError`; missing config raises `ConfigurationError`.

```ruby
begin
  LavendaPay::Customers::Create.call(params)
rescue LavendaPay::UnprocessableError => error
  error.errors # => {"user_email" => ["is invalid"]}
end
```

## Webhooks

Lavenda Pay POSTs JSON to your endpoint with the shared secret in the header exposed as
`LavendaPay::Webhooks::Signature::HEADER`.

### Rails engine (recommended)

Mount the engine and give it a handler. It verifies the secret, parses the payload and calls your handler with a
`LavendaPay::Webhooks::Event` for every supported event.

```ruby
# config/routes.rb
mount LavendaPay::Engine => "/webhooks/lavenda_pay"

# config/initializers/lavenda_pay.rb
LavendaPay.configure do |config|
  # ...base_url, api_token, webhook_secret
  config.on_event = ->(event) { MyApp::Webhooks::Process.call(event:) } # any callable
end
```

Responses: `200` for handled and unsupported events, `401` for a wrong or missing secret, `422` for an invalid payload.
Exceptions raised by the handler are not rescued, so the request fails with `500` and the sender retries; make the
handler idempotent (see `event.idempotency_key`). Without `on_event` configured the endpoint raises a
`ConfigurationError`.

### Your own controller

```ruby
class Webhooks::LavendaPayController < ActionController::API
  def create
    event = LavendaPay::Webhooks::ConstructEvent.call(
      request.raw_post, request.headers[LavendaPay::Webhooks::Signature::HEADER]
    )

    return head :ok unless event.supported?

    if event.order?
      order = Order.find_by!(gateway_order_pid: event.pid)
      order.update!(status: event.data["status"], paid: event.name == "order_paid")
    end

    head :ok
  rescue LavendaPay::InvalidWebhookSignatureError
    head :unauthorized
  rescue LavendaPay::InvalidWebhookPayloadError
    head :unprocessable_entity
  end
end
```

`LavendaPay::Webhooks::VerifySignature.call(secret)` and `LavendaPay::Webhooks::ParseEvent.call(raw_body)` are
available separately. `event.idempotency_key` (`"order_paid:Order:order_123"`) is stable across redeliveries; use it to de-duplicate.
Supported events: `order_created`, `order_pending`, `order_partially_paid`, `order_paid`, `order_refund_requested`,
`order_refunded`, `order_cancelled`, `payment_created`, `payment_processing`, `payment_pending`, `payment_paid`,
`payment_refused`, `payment_refund_requested`, `payment_refunded`, `payment_partially_refunded`, `payment_canceled`.

## Development

```bash
bundle install
bundle exec rspec
```
