# frozen_string_literal: true

require_relative "lib/beautty/version"

Gem::Specification.new do |spec|
  spec.name          = "beautty"
  spec.version       = Beautty::VERSION
  spec.authors       = ["Your Name"] # TODO: Replace with your name
  spec.email         = ["your.email@example.com"] # TODO: Replace with your email

  spec.summary       = %q{A Flexbox-inspired TUI layout framework.}
  spec.description   = %q{Beautty provides tools to build Text User Interfaces using layout principles inspired by CSS Flexbox.}
  spec.homepage      = "TODO: Put your gem's website or repo URL here."
  spec.license       = "MIT" # Or your preferred license
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0") # Adjust as needed

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'https://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your source repository URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your changelog URL here."

  # Specify which files should be added to the gem when it is packaged.
  # Ensure these files exist or adjust the patterns.
  spec.files         = Dir.chdir(File.expand_path('.', __dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Add runtime dependencies
  # spec.add_dependency "curses", "~> 1.4"
  spec.add_dependency "ruby-termios", ">= 0"

  # Add development dependencies (optional, often in Gemfile)
  # spec.add_development_dependency "bundler", "~> 2.0"
  # spec.add_development_dependency "rake", "~> 13.0"
  # spec.add_development_dependency "minitest", "~> 5.0"
end 