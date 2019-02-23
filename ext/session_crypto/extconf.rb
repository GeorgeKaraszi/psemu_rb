# frozen_string_literal: true

require "mkmf-rice"

# rubocop:disable Style/GlobalVars
extension_name                   = "session_crypto"
$CXXFLAGS                       += " -Wall -std=c++14"
MakeMakefile::CONFIG["optflags"] = ""

cryptopp_path = [
  # Inside [Project Directory]/ext/session_crypto
  "../../vendor/cryptopp",
  # In [Project Directory]
  "vendor/cryptopp",
  # When makefile is generated to: [Project Directory]/tmp/[compiler]/[build_name]/[ruby version]/...
  "../../../../vendor/cryptopp"
].map! { |path| File.expand_path(path) }.detect { |path| Dir.exist?(path) }.yield_self { |path| Pathname.new(path) }

cryptopp_headers  = cryptopp_path.join("include").to_s
cryptopp_lib      = cryptopp_path.join("lib").to_s

unless find_library("cryptopp", nil, cryptopp_path.to_s, cryptopp_lib)
  puts ">>>>> Can't find cryptopp library! <<<<<"
  raise(">>>>> Try running `rake compile_cryptopp` before. Or simply use `rake compile_all`<<<<<")
end

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

dir_config(extension_name, [cryptopp_headers], [cryptopp_lib])
create_makefile(File.join(extension_name, extension_name))

# rubocop:enable Style/GlobalVars
