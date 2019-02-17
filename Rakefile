# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/extensiontask"
require "rspec/core/rake_task"

Rake::ExtensionTask.new("session_crypto") do |ext|
  ext.lib_dir = "lib/ps_emu/session"
end
RSpec::Core::RakeTask.new(:spec)

task default: [:clobber, :compile, :spec]
