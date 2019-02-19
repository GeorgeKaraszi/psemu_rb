# frozen_string_literal: true

module PSEmu
  class SessionPlayer
    attr_reader :client_endpoint, :session_crypto
    delegate :server_priv_key,
             :server_pub_key,
             :server_challenge,
             :client_challenge,
             :server_time,
             to: :session_crypto

    CS_STATES = {
      CS_STARTED:   0,
      CS_CHALLENGE: 1,
      CS_FINISHED:  2
    }.freeze

    def initialize(client_endpoint)
      @client_endpoint = client_endpoint
      @cs_state        = CS_STATES[:CS_STARTED]
      @session_crypto  = SessionCrypto.new
    end

    def next_crypto_state!
      @cs_state += 1 unless crypto_state == :CS_FINISHED
    end

    def crypto_state
      CS_STATES.key(@cs_state)
    end

    def send_msg(message)
      message = message.to_byte_string unless message.encoding == Encoding::BINARY
      log_message(message)
      client_endpoint.reply(message.b)
    end
    alias send_msg! send_msg

    def generate_dh_key_pairs!(packet)
      session_crypto.client_time      = packet[:client_time].bytes
      session_crypto.client_challenge = packet[:challenge].bytes
      session_crypto.generate_dh_key_pairs!(packet[:p].bytes, packet[:g].bytes)
      next_crypto_state!
    end

    private

    def log_message(message)
      puts message.b
      puts "-------------------------------------------------------"
      puts "Sending Message: "
      puts "  ->(HEX):   #{message.to_hex(HexByte::READABLE)}"
      puts "  ->(BYTES): #{message.bytes}"
      puts "  ->(SIZE): #{message.bytesize}"
    end
  end
end
