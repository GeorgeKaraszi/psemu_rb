# frozen_string_literal: true

require "socket"

module PSEmu
  class Server
    ClientMessage = Struct.new(:packet) do
      delegate_missing_to :packet

      def initialize(received_packet)
        self[:packet] = StringIO.new(received_packet).tap(&:binmode)
      end

      def read_byte(peek = false)
        read_bytes(1, peek)
      end

      def read_hex(bytes = 1, peek = false, array: false)
        read_bytes(bytes, peek).to_hex(array ? HexByte::ARRAY : nil)
      end

      def read_bytes(bytes, peek = false)
        packet.read(bytes).tap do
          packet.pos -= bytes if peek && packet.pos.positive?
        end
      end
    end

    def process_packet!(session, message)
      message = ClientMessage.new(message)

      if message.read_byte(true).to_base16.zero?
        process_control_packet(session, message)
      else
        process_non_control_packet(session, message)
      end
    end

    def process_control_packet(session, message)
      message.pos += 1 # Skip first byte since its always zero and has no flags
      opcode = PSEmu::Packet::CONTROL_OP_CODES[message.read_byte.to_hex]

      case opcode
      when :OP_ClientStart
        encoded_message = PSEmu::ClientServerStart.decode_and_encode(message)
        session.send_msg!(encoded_message)
      else
        puts "Unknown packet #{opcode}"
      end
    end

    def process_non_control_packet(session, message)
      packet_header = PSEmu::Packet.packet_headers!(message)
      opcode        = PSEmu::Packet::CRYPTO_OP_CODES[packet_header[:packet_type]]
      case opcode
      when :PT_Crypto
        process_crypto_packet(session, message)
      when :PT_NORMAL
        puts "Do something with PT_NORMAL!!!"
      else
        puts "UNKNOWN CONTROL PACKET"
        pp packet_header
        puts "---------"
      end
    end

    def process_crypto_packet(session, message)
      case session.crypto_state
      when :CS_STARTED
        decoded_packet = PSEmu::ClientChallengeXChg.decode(message)
        session.generate_dh_key_pairs!(decoded_packet)
        encoded_message = PSEmu::ServerChallengeXChg.decode_and_encode(session)
        session.send_msg!(encoded_message)
      when :CS_CHALLENGE
        puts "SUPER CHALLENGED"
      else
        puts "UNKNOWN PACKET STATE! #{session.crypto_state}"
      end
    end
  end
end
