# frozen_string_literal: true

require "bundler/setup"
require "ps_emu"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each(&method(:require))
Dir["#{File.dirname(__FILE__)}/**/*examples.rb"].each(&method(:require))

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
