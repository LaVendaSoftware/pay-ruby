require_relative "lib/lavenda_pay/version"

Gem::Specification.new do |spec|
  spec.name = "lavenda-pay-ruby"
  spec.version = LavendaPay::VERSION
  spec.authors = ["La Venda Software"]

  spec.summary = "Ruby client for the Lavenda Pay payments API."
  spec.description = "Create customers and orders on Lavenda Pay and verify/parse its webhooks, " \
    "without depending on Rails."
  spec.homepage = "https://github.com/LaVendaSoftware/pay-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*.rb", "app/**/*.rb", "config/routes.rb", "README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]


  spec.add_development_dependency "actionpack", ">= 7.1"
  spec.add_development_dependency "railties", ">= 7.1"
  spec.add_development_dependency "rack-test", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "webmock", "~> 3.23"
end
