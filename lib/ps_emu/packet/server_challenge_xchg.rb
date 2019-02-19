# frozen_string_literal: true

module PSEmu
  module ServerChallengeXChg
    def self.decode_and_encode(session)
      decoded_message = decode(session)
      encode(decoded_message)
    end

    def self.encode_filler(value, type)
      case type
      when :uint_16
        return [value, 0x00] if value.is_a?(Integer) && value < 255
      when :uint_32
        if value.is_a?(Integer) && value < 0xFFFFFF
          missing_bytes = 4 - value.to_byte_string.bytesize
          return [value, *missing_bytes.times.map { 0x00 }]
        end
      else
        value
      end

      value
    end
    def self.decode(session)

      [
       2,
       1,
       session.server_time.to_hex,
       session.server_challenge,
       0,
       1,
       [0x03, 0x07, 0x00, 0x00, 0x00, 0x0C, 0x00],
       [16, 0x00],
       session.server_pub_key,
       14
      ]
    end

    def self.encode(decoded_message)
      if decoded_message.respond_to?(:values)
        decoded_message.values
      else
        decoded_message
      end.to_byte_string
    end
  end
end
