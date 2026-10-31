# Lavenda Pay Ruby

Ruby client for the [Lavenda Pay](https://github.com/LaVendaSoftware/pay-ruby) payments API.
Framework-agnostic (no Rails/ActiveSupport dependency): create customers and orders, and verify/parse webhooks.

## Installation

```ruby
gem "lavenda-pay-ruby"
```

## Configuration

Settings are read from `LAVENDA_PAY_*` environment variables and, inside a Rails app, from the `lavenda_pay`
credentials, so a Rails app needs no initializer:

```yaml
# bin/rails credentials:edit
lavenda_pay:
  base_url: https://pay.example.com
  api_token: ...
  webhook_secret: ...
```

| Setting          | Environment variable         | Credential                     |
| ---------------- | ---------------------------- | ------------------------------ |
| `base_url`       | `LAVENDA_PAY_BASE_URL`       | `lavenda_pay.base_url`         |
| `api_token`      | `LAVENDA_PAY_API_TOKEN`      | `lavenda_pay.api_token`        |
| `webhook_secret` | `LAVENDA_PAY_WEBHOOK_SECRET` | `lavenda_pay.webhook_secret`   |

`base_url` is the root of the Lavenda Pay installation, without the `/api` suffix. Use the company domain: the API
accepts any host, but the public order pages are only served on the company's own domain.

Values set explicitly win over both:

```ruby
LavendaPay.configure do |config|
  config.base_url = "https://pay.example.com"
  config.logger = Rails.logger
end
```

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

# Public payment page for the order, built from `base_url`.
LavendaPay::Url.order_path(order.pid) # => "https://pay.example.com/orders/order_..."
```

## Payments

Preview the options for the amount the merchant wants to receive, before redirecting the customer to
the order's payment page. The card fee is passed on to the customer; Pix passes nothing on, so its
`fee` and `net_amount` are `nil`, meaning unknown rather than zero. A simulation binds no price: the
customer chooses the installments on the payment page, where the server computes the amount again.
Card data never goes through the API.

```ruby
simulation = LavendaPay::Payments::Simulate.call(amount: 100.0)
simulation.options.map { |o| [o.payment_method_kind, o.installment_count, o.installment_value, o.total] }
# => [["pix", 1, 100.0, 100.0], ["credit_card", 1, 102.54, 102.54], ["credit_card", 2, 51.27, 102.54], ...]

LavendaPay::Url.order_path(order.pid) # send the customer here to choose and pay
```

Sandbox only: confirm a pending payment as if the customer had paid it, to test your payment flow
end to end. LavendaPay marks it as paid and, when the gateway supports it, confirms it there too.
The endpoint does not exist in production, where it raises `LavendaPay::NotFoundError`.

```ruby
# The payment pid comes from the payment outcome webhooks.
payment = LavendaPay::Payments::Confirm.call("pay_...")
payment.status               # => "paid"
payment.gateway_confirmation # => "confirmed", "failed" or "unsupported"
```

## Payment links

A reusable public page: each payer identifies themself there and generates their own order. Omit
`amount` to let the payer type it. `amount` is the base price: what a payment charges depends on
the payment method.

```ruby
payment_link = LavendaPay::PaymentLinks::Create.call(
  name: "Mentoria",
  billing_type: "undefined", # "undefined" (Pix and card), "pix" or "credit_card"
  charge_type: "detached",
  amount: 150.0,
  end_date: "2027-12-31",
  due_date_limit_days: 3,
  eid: "LINK-0123",
  success_url: "https://example.com/thanks",
  auto_redirect: true,
  requires_billing_address: false
)
payment_link.url    # => the public page to share
payment_link.status # => "active"

LavendaPay::PaymentLinks::Find.call(payment_link.pid)
LavendaPay::PaymentLinks::List.call(name: "Mentoria", eid: "LINK-0123", page: 1)
LavendaPay::PaymentLinks::End.call(payment_link.pid) # final; existing orders stay as they are
```

Orders generated by a link carry its `payment_link_pid`.

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
