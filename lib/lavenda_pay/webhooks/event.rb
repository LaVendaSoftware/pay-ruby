module LavendaPay
  module Webhooks
    # A parsed webhook delivery from Lavenda Pay:
    #   {"event" => "order_paid", "resource_type" => "Order",
    #    "resource_pid" => "order_123", "data" => {...}}
    class Event
      ORDER_EVENTS = %w[
        order_created order_pending order_partially_paid order_paid
        order_refund_requested order_refunded order_cancelled
      ].freeze

      PAYMENT_EVENTS = %w[
        payment_created payment_processing payment_pending payment_paid
        payment_refused payment_refund_requested payment_refunded
        payment_partially_refunded payment_canceled
      ].freeze

      SUPPORTED_EVENTS = (ORDER_EVENTS + PAYMENT_EVENTS).freeze

      REQUIRED_KEYS = %w[event resource_type data].freeze

      attr_reader :payload

      # Raises InvalidWebhookPayloadError when required keys are missing.
      def self.parse(payload)
        payload = JSON.parse(payload) if payload.is_a?(String)
        raise InvalidWebhookPayloadError, "payload must be a JSON object" unless payload.is_a?(Hash)

        payload = payload.transform_keys(&:to_s)
        missing = REQUIRED_KEYS.reject { |key| present?(payload[key]) }
        missing << "resource_pid" unless present?(payload["resource_pid"]) || present?(payload["resource_id"])
        raise InvalidWebhookPayloadError, "missing keys: #{missing.join(", ")}" unless missing.empty?

        new(payload)
      rescue JSON::ParserError => error
        raise InvalidWebhookPayloadError, "invalid JSON: #{error.message}"
      end

      def self.present?(value) = !(value.nil? || (value.respond_to?(:empty?) && value.empty?))

      def initialize(payload)
        @payload = payload
      end

      def name = payload["event"]

      def resource_type = payload["resource_type"]

      # Lavenda Pay sends `resource_pid`; older consumers used `resource_id`.
      def resource_id = (payload["resource_pid"] || payload["resource_id"]).to_s

      def data = payload["data"]

      # pid of the order/payment the event is about.
      def pid = data.is_a?(Hash) ? data["pid"] : nil

      def supported? = SUPPORTED_EVENTS.include?(name)

      def order? = name.to_s.start_with?("order_")

      def payment? = name.to_s.start_with?("payment_")

      def order = order? && data.is_a?(Hash) ? Order.new(data) : nil

      # Stable key for de-duplicating deliveries.
      def idempotency_key = [name, resource_type, resource_id].join(":")
    end
  end
end
