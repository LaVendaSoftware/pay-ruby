module LavendaPay
  # Thin read-only wrapper over an API payload. Keys are exposed as methods
  # (`customer.pid`) and via `#[]`; the raw payload stays available as `#to_h`.
  class Resource
    attr_reader :attributes
    alias_method :to_h, :attributes

    def initialize(attributes)
      @attributes = (attributes || {}).transform_keys(&:to_s).freeze
    end

    def [](key) = attributes[key.to_s]

    def pid = attributes["pid"]

    def respond_to_missing?(name, include_private = false)
      attributes.key?(name.to_s) || super
    end

    def method_missing(name, *args)
      return attributes[name.to_s] if args.empty? && attributes.key?(name.to_s)

      super
    end

    def ==(other) = other.is_a?(self.class) && other.attributes == attributes

    def inspect = "#<#{self.class.name} #{attributes.inspect}>"
  end
end
