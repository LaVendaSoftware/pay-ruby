module LavendaPay
  # Base class for every API operation. Each one is invoked as
  # `LavendaPay::Customers::Create.call(params)` using the global
  # configuration, or on an explicit client:
  #
  #   LavendaPay::Customers::Create.new(client: client).call(params)
  class Operation
    def self.call(*args, **kwargs) = new.call(*args, **kwargs)

    def initialize(client: LavendaPay.client)
      @client = client
    end

    private

    attr_reader :client

    def http = client.http

    def escape(value) = URI.encode_www_form_component(value.to_s)
  end
end
