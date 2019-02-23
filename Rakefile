# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/extensiontask"
require "rspec/core/rake_task"

def enable_msys_apps!
  RubyInstaller::Runtime.enable_msys_apps if RUBY_PLATFORM.match?(/mingw/)
end

def cryptopp_dirs
  {
    src_location: File.expand_path("ext/externals/cryptopp"),
    install_dir:  File.expand_path("vendor/cryptopp")
  }
end

Rake::ExtensionTask.new("session_crypto") do |ext|
  ext.lib_dir = "lib/ps_emu/session"
  ext.cross_platform
end
RSpec::Core::RakeTask.new(:spec)

task :compile_cryptopp do
  enable_msys_apps!

  cryptopp_paths = cryptopp_dirs
  system("git submodule update --init") unless Dir.exist?(cryptopp_paths[:src_location])
  FileUtils.mkdir_p(cryptopp_paths[:install_dir])

  Dir.chdir(cryptopp_paths[:src_location]) do
    system("make static CXXFLAGS='-std=c++14'")
    system("make install PREFIX=#{cryptopp_paths[:install_dir]}")
  end
end

task :clobber_cryptopp do
  enable_msys_apps!

  cryptopp_paths = cryptopp_dirs
  FileUtils.rm_rf(cryptopp_paths[:install_dir])
  Dir.chdir(cryptopp_paths[:src_location]) { system("make clean") } if Dir.exist?(cryptopp_paths[:src_location])
end

task compile_all:       [:clobber, :compile_cryptopp, :compile]
task clean_compile_all: [:clobber_cryptopp, :compile_all]
task default:           [:compile_all, :spec]
