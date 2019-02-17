# frozen_string_literal: true

require "mkmf-rice"

# rubocop:disable Style/GlobalVars
extension_name                   = "session_crypto"
$CXXFLAGS                       += " -Wall -std=c++14"
MakeMakefile::CONFIG["optflags"] = ""
brew_crypto                      = Pathname.new(`brew --prefix cryptopp`.chomp)
cppflags                         = brew_crypto.join("include", "cryptopp").to_s
ldflags                          = brew_crypto.join("lib").to_s

found_crypto_library = find_library(
  "cryptopp",
  nil,
  "/usr/local/lib",
  "/usr/local/lib/cryptopp",
  "/opt/local/lib",
  "/opt/local/lib/cryptopp",
  "/usr/lib",
  "/usr/lib/cryptopp"
)

error("Can't find cryptopp library!") unless found_crypto_library

# Shamefully coping over OJ's extconf example.

parts    = RUBY_DESCRIPTION.split(" ")
type     = parts[0]
type     = type[4..-1] if type.start_with?("tcs-")
platform = RUBY_PLATFORM
version  = RUBY_VERSION.split(".")
puts ">>>>> Creating Makefile for #{type} version #{RUBY_VERSION} on #{platform} <<<<<"

{
  (type.upcase + "_RUBY") => nil,
  "RUBY_TYPE" => type,
  "RUBY_VERSION" => RUBY_VERSION,
  "RUBY_VERSION_MAJOR" => version[0],
  "RUBY_VERSION_MINOR" => version[1],
  "RUBY_VERSION_MICRO" => version[2]
}.each_pair do |k, v|
  $CPPFLAGS += v.nil? ? " -D#{k}" : " -D#{k}=#{v}"
end

dir_config(extension_name, [cppflags], [ldflags])
create_makefile(File.join(extension_name, extension_name))

# rubocop:enable Style/GlobalVars
