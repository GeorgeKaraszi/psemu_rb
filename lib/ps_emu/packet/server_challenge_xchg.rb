# frozen_string_literal: true

module PSEmu
  module ServerChallengeXChg
    def self.decode_and_encode(session)
      decoded_message = decode(session)
      encode(decoded_message)
    end

    def self.decode(session)
      {
        unk0:              2,
        unk1:              1,
        server_time:       session.server_time,
        challenge:         session.server_challenge,
        unk_challenge_end: 0,
        unk_objects:       1,
        unk2:              [0x03, 0x07, 0x00, 0x00, 0x00, 0x0C, 0x00],
        pub_key_len:       16,
        pub_key:           session.server_pub_key,
        unk3:              14
      }
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
