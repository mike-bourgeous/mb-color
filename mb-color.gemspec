# frozen_string_literal: true

require_relative "lib/mb/color/version"

Gem::Specification.new do |spec|
  spec.name = "mb-color"
  spec.version = MB::Color::VERSION
  spec.authors = ["Mike Bourgeous"]
  spec.email = ["mike@mikebourgeous.com"]

  spec.summary = "Color conversion functions"
  spec.description = "Color conversion functions from the Code, Sound & Surround video series"
  spec.homepage = "https://github.com/mike-bourgeous/mb-color"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Development dependencies
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'mb-math'
  spec.add_development_dependency 'mb-util'

  # Release dependencies

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
