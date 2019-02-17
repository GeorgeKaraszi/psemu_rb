# frozen_string_literal: true

module PSEmu
  module Packet
    CRYPTO_OP_CODES = {
      0 => :PT_Crypto,
      1 => :PT_Normal
    }.freeze

    CONTROL_OP_CODES = {
      "00" => :OP_HandleGamePacket,
      "01" => :OP_ClientStart,
      "02" => :OP_ServerStart,
      "03" => :OP_MultiPacket,
      "04" => :OP_Unk4,
      "05" => :OP_TeardownConnection,
      "06" => :OP_Unk6,
      "07" => :OP_ControlSync,

      # // 0x08
      "08" => :OP_ControlSyncResp,
      "09" => :OP_SlottedMetaPacket0,
      "0a" => :OP_SlottedMetaPacket1,
      "0b" => :OP_SlottedMetaPacket2,
      "0c" => :OP_SlottedMetaPacket3,
      "0d" => :OP_SlottedMetaPacket4,
      "0e" => :OP_SlottedMetaPacket5,
      "0f" => :OP_SlottedMetaPacket6,

      # // 0x10-1F
      "10" => :OP_SlottedMetaPacket7,
      "11" => :OP_RelatedA0,
      "12" => :OP_RelatedA1,
      "13" => :OP_RelatedA2,
      "14" => :OP_RelatedA3,
      "15" => :OP_RelatedB0,
      "16" => :OP_RelatedB1,
      "17" => :OP_RelatedB2,

      # // 0x18
      "18" => :OP_RelatedB3,
      "19" => :OP_MultiPacketEx,
      "1a" => :OP_Unk26,
      "1b" => :OP_Unk27,
      "1c" => :OP_Unk28,
      "1d" => :OP_ConnectionClose,
      "1e" => :OP_Unk30
    }.freeze

    CONTROL_OP_CODES_INVERSE = CONTROL_OP_CODES.invert.freeze

    def self.packet_headers!(message)
      flags = message.read_byte.to_base16
      {
        packet_type:   (flags & 0b11110000) >> 4,
        unused:        (flags & 0b1000) >> 3,
        secured:       (flags & 0b100) >> 2,
        advanced:      (flags & 0b10) >> 1,
        len_specified: (flags & 0b1),
        seq_num:       message.read_bytes(2)
      }.tap do |hash|
        message.pos += 1 if hash[:secured].positive?
      end
    end
  end
end
