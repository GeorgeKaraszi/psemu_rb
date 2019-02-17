# frozen_string_literal: true

require "bundler/gem_tasks"
require 'rake/extensiontask'
require "rspec/core/rake_task"

Rake::ExtensionTask.new('session_crypto')
RSpec::Core::RakeTask.new(:spec)

task default: [:clobber, :compile, :spec]
