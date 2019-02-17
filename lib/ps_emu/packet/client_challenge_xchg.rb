# frozen_string_literal: true

module PSEmu
  module ClientChallengeXChg
    def self.decode(message)
      {}.tap do |hash|
        hash[:unk0]              = message.read_byte
        hash[:unk1]              = message.read_byte
        hash[:client_time]       = message.read_bytes(4)
        hash[:challenge]         = message.read_bytes(12)
        hash[:unk_end_challenge] = message.read_byte
        hash[:unk_objects0]      = message.read_byte
        hash[:unk_object_type]   = message.read_bytes(2)
        hash[:unk2]              = message.read_bytes(4)
        hash[:p_len]             = message.read_bytes(2)
        hash[:p]                 = message.read_bytes(16)
        hash[:g_len]             = message.read_bytes(2)
        hash[:g]                 = message.read_bytes(16)
        hash[:unk_end0]          = message.read_byte
        hash[:unk_end1]          = message.read_byte
        hash[:unk_objects1]      = message.read_byte
        hash[:unk3]              = message.read_bytes(4)
        hash[:unk_end2]          = message.read_byte
      end
    end
  end
end
