# frozen_string_literal: true

module PSEmu
  class SessionPlayer
    attr_reader :client_endpoint
    attr_accessor :client_time, :client_challenge,
                  :server_privet_key, :server_public_key,
                  :server_time, :server_challenge,
                  :dec_mac_key, :enc_mac_key

    delegate :reply, to: :client_endpoint
    alias send_msg! reply

    CS_STATES = {
      CS_STARTED:   0,
      CS_CHALLENGE: 1,
      CS_FINISHED:  2
    }.freeze

    def initialize(client_endpoint)
      @client_endpoint = client_endpoint
      @cs_state        = CS_STATES[:CS_STARTED]
    end

    def next_crypto_state!
      @cs_state += 1 unless crypto_state == :CS_FINISHED
    end

    def crypto_state
      CS_STATES.key(@cs_state)
    end

    def generate_crypto1!(packet)
      dh = OpenSSL::PKey::DH.new
      p  = packet[:p].bytes.inject(0) { |sum, byte| sum * 256 + byte }.to_bn
      g  = packet[:g].bytes.inject(0) { |sum, byte| sum * 256 + byte }.to_bn

      dh.set_pqg(p, nil, g)
      dh.generate_key!

      # pub = 1F29DCBDADC70A65967766D3A174BFE6
      # prv = 4B95FFE5CC0DCF6B7143031323066CD1

      @server_privet_key = dh.priv_key
      @server_public_key = dh.pub_key
      @client_time       = packet[:client_time]
      @client_challenge  = packet[:challenge]
      @server_challenge  = SecureRandom.bytes(12).bytes
      @server_time       = Time.now.to_i
      next_crypto_state!
    end
  end
end
