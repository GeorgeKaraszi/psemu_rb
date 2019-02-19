# frozen_string_literal: true

module PSEmu
  module ClientServerStart
    STATIC_UNK0 = "000000000001d300000002"

    def self.decode_and_encode(message)
      client_nonce = decode(message).dig(:client_nonce)
      server_nonce = SecureRandom.bytes(4).to_hex
      encode(client_nonce, server_nonce)
    end

    def self.decode(message)
      {}.tap do |hash|
        hash[:unk0]         = message.read_bytes(4)
        hash[:client_nonce] = message.read_bytes(4)
        hash[:unk1]         = message.read_bytes(4)
      end
    end

    def self.encode(client_nonce, server_nonce)
      [
        0x00,
        Packet::CONTROL_OP_CODES_INVERSE[:OP_ServerStart],
        client_nonce,
        server_nonce,
        STATIC_UNK0
      ].to_byte_string
    end
  end
end
