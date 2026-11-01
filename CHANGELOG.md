# Changelog

## 0.0.4

- Add `LavendaPay::PaymentLinks` (`Create`, `Find`, `List`, `End`) and `LavendaPay::PaymentLink`.
- `LavendaPay::Order` exposes `payment_link_pid`.
- Add `LavendaPay::Payments::Simulate` to preview the options for an amount, with the card fee passed on to the customer.
- `LavendaPay::Orders::Create` accepts `max_installment_count`, and `LavendaPay::Order` exposes it.
- `LavendaPay::Payment` exposes `installment_count`, `surcharge` and `charged_total`.

## 0.0.3

- Add `LavendaPay::Payments::Confirm` to confirm a pending payment outside production.

## 0.0.2

- Read settings from the `lavenda_pay` Rails credentials when the environment variable is not set.
- Add `LavendaPay::Url.order_path` to build the public order page link.

## 0.0.1

- Initial release: customers, orders and webhook handling.
