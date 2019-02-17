# frozen_string_literal: true

require "active_support/all"
ActiveSupport.eager_load!

require "ps_emu/version"

require "hex_byte"

require "ps_emu/session/session_crypto" # C Extension
require "ps_emu/session/session_player"
require "ps_emu/session/session_manager"

require "ps_emu/packet/packet"
require "ps_emu/packet/client_server_start"
require "ps_emu/packet/client_challenge_xchg"
require "ps_emu/packet/server_challenge_xchg"
require "ps_emu/server"

module PSEmu
  class Error < StandardError; end

  def self.sessions
    Thread.current[:sessions] ||= SessionManager.new
  end
end
