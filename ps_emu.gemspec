# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ps_emu/version"

Gem::Specification.new do |spec|
  spec.name          = "ps_emu"
  spec.version       = PSEmu::VERSION
  spec.authors       = ["George Karaszi"]
  spec.email         = ["georgekaraszi@gmail.com"]

  spec.summary       = "PS EMU"
  spec.description   = "PS EMU"
  spec.homepage      = "http://google.com"
  spec.license       = "MIT"
  spec.extensions    = "ext/extconf.rb"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "http://mygemserver.com"

    spec.metadata["homepage_uri"] = spec.homepage
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir["README.md", "lib/**/*", "ext/**/*", "login_server/**/*"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "login_server"]

  spec.add_dependency("activesupport", "~> 5.0")

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rake-compiler"
  spec.add_development_dependency "rspec", "~> 3.0"
  # spec.add_dependency "rice"
end
