# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/extensiontask"
require "rspec/core/rake_task"

Rake::ExtensionTask.new("session_crypto") do |ext|
  ext.lib_dir = "lib/ps_emu/session"
  ext.cross_platform
end
RSpec::Core::RakeTask.new(:spec)

task :compile_cryptopp do
  cryptopp_src_location = File.expand_path("ext/externals/cryptopp")
  install_location      = File.expand_path("ext/libraries/cryptopp")

  RubyInstaller::Runtime.enable_msys_apps if RUBY_PLATFORM.match?(/mingw/)
  system("git submodule update --init") unless Dir.exist?(cryptopp_src_location)
  FileUtils.mkdir_p(install_location)

  Dir.chdir(cryptopp_src_location) do
    system("make static CXXFLAGS='-std=c++14'")
    system("make install PREFIX=#{install_location}")
  end
end

task :clobber_cryptopp do
  cryptopp_src_location = File.expand_path("ext/externals/cryptopp")
  install_location      = File.expand_path("ext/libraries/cryptopp")
  FileUtils.rm_rf(install_location)
  Dir.chdir(cryptopp_src_location) { system("make clean") } if Dir.exist?(cryptopp_src_location)

end

task :compile_all => [:clobber, :clobber_cryptopp, :compile_cryptopp, :compile]
task default: [:compile_all, :spec]
