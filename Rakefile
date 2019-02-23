# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/extensiontask"
require "rspec/core/rake_task"

# If using Windows and have (not to mention required) RuberInstaller, we need to enable linux-ish make/g++ tools
def enable_msys_apps!
  return if @enabled_msys || !defined?(RubyInstaller)

  RubyInstaller::Runtime.enable_msys_apps
  @enabled_msys = true
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
    system("make static cryptest.exe CXXFLAGS='-std=c++14 -fPIC'")
    system("make install PREFIX=#{cryptopp_paths[:install_dir]}")
  end

  Rake::Task["cryptopp_test"].invoke
end

task :clobber_cryptopp do
  enable_msys_apps!

  cryptopp_paths = cryptopp_dirs
  FileUtils.rm_rf(cryptopp_paths[:install_dir])

  if Dir.exist?(cryptopp_paths[:src_location])
    Dir.chdir(cryptopp_paths[:src_location]) do
      system("make clean")
    end
  end
end

task :cryptopp_test do
  enable_msys_apps!
  lib_path     = Pathname(cryptopp_dirs[:install_dir]).join("lib").to_s
  header_path  = Pathname(cryptopp_dirs[:install_dir]).join("include").to_s
  testing_path = File.expand_path("tmp/cryptop_test")
  FileUtils.mkdir_p(testing_path)

  Dir.chdir(testing_path) do
    src = <<~CPP_SRC
      #include <cryptopp/sha.h>
      #include <string>
      #include <iostream>
      using namespace CryptoPP;
      using namespace std;
      int main()
      {
        byte digest[SHA1::DIGESTSIZE];
        string data = "Hello World!";
        SHA1().CalculateDigest(digest, (byte*) data.c_str(), data.length());
        cout << endl
             << "\t\t----------------------------------------------"
             << endl << endl
             << "\t\t  Successfully Compiled & Called Crypto++!"
             << endl << endl
             << "\t\t----------------------------------------------"
             << endl << endl;
        return 0;
      }
    CPP_SRC

    File.write("test.cpp", src)
    system("g++", "test.cpp", "-I#{header_path}", "-L#{lib_path}", "-lcryptopp", "-o", "test")
    system("./test")
  end
ensure
  FileUtils.rm_rf(testing_path)
end

# Concatenated tasks / project commands
task ccompile:          [:cryptopp_test, :clobber, :compile]
task compile_all:       [:compile_cryptopp, :cryptopp_test, :ccompile]
task clean_compile_all: [:clobber_cryptopp, :compile_all]
task default:           [:compile_all, :spec]
