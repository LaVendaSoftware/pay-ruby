GEM_NAME = lavenda-pay-ruby
GEM_VERSION = $(shell ruby -Ilib -e 'require "lavenda_pay/version"; print LavendaPay::VERSION')
GEM_FILE = $(GEM_NAME)-$(GEM_VERSION).gem

.PHONY: build publish

build:
	gem build $(GEM_NAME).gemspec

publish: build
	@echo "gem push $(GEM_FILE)"
	@gem push $(GEM_FILE)
