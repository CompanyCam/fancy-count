# frozen_string_literal: true

require_relative "lib/fancy_count/version"

Gem::Specification.new do |spec|
  spec.name          = "fancy_count"
  spec.version       = FancyCount::VERSION
  spec.authors       = ["CompanyCam Engineering"]
  spec.email         = ["engineering@companycam.com"]

  spec.summary       = "Yet Another Counter Library"
  spec.description   = "A small library to count things. Use Redis, Memory, or bring your own storage!"
  spec.homepage      = "https://companycam.com"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.2", "< 7"
  spec.add_dependency "activesupport", ">= 4.2", "< 7"
  spec.add_dependency "discard", ">= 1.0"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec", ">= 3.5.0"
  spec.add_development_dependency "database_cleaner-active_record", "~> 2.0"
  spec.add_development_dependency "with_model", "~> 2.0"
  spec.add_development_dependency "sqlite3"
end
