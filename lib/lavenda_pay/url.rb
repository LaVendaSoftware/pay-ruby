require "uri"

module LavendaPay
  # Links to the public Lavenda Pay pages, built from `base_url`.
  #
  #   LavendaPay::Url.order_path("order_...") # => "https://.../orders/order_..."
  module Url
    module_function

    def order_path(pid, configuration: LavendaPay.configuration)
      "#{configuration.base_url.to_s.chomp("/")}/orders/#{URI.encode_www_form_component(pid.to_s)}"
    end
  end
end
