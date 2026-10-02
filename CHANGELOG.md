# Changelog

## 0.0.2

- Read settings from the `lavenda_pay` Rails credentials when the environment variable is not set.
- Add `checkout_url` setting (defaults to `base_url`) and `LavendaPay::Url.order_path`.

## 0.1.0

- Initial release: customers, orders and webhook handling extracted from the
  Catavento and Lavenda Store adapters.
