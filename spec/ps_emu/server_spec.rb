# frozen_string_literal: true

module PSEmu
  RSpec.describe Server do
    # let!(:client) { PSClient.new }
    #
    # after { client.terminate! }

    describe "Client Start" do
      let(:client_msg)   { PSClientMessage.hex("00, 01, 00, 00, 00, 02, 00, 26, 1e, 27, 00, 00, 01, f0") }
      let(:op_code)      { :OP_ClientStart }
      let(:unk1)         { 0x00000002 }
      let(:client_nonce) { 0x00261E27 }
      let(:unk2)         { 0x000001F0 }

      it "works" do
        client.send_to(client_msg)
        client_packet = client.server_client_response!

        expect(client_packet).to be_a(PSEmu::ControlPacket)
        expect(client_packet.op_code).to eq(op_code)
        expect(client_packet.unk1.to_hex_byte).to eq(unk1)
        expect(client_packet.client_nonce.to_hex_byte).to eq(client_nonce)
        expect(client_packet.unk2.to_hex_byte).to eq(unk2)
      end
    end

    describe "Server Start" do
      let(:encoded_buffer) { PSClientMessage.hex("00 02 00 26 1E 27 51 BD C1 CE 00 00 00 00 00 01 D3 00 00 00 02") }
      it "works too" do
        client_n     = 0x00261E27
        server_n     = 0x51BDC1CE
        unknown      = [0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xD3, 0x00, 0x00, 0x00, 0x02]
        start_server = PSEmu::ServerStart.new(client_n, server_n, unknown)
        expect(start_server.encode.bytes).to eq(encoded_buffer.bytes)
      end
    end

    describe "ClientChallengeXchg" do
      let(:client_message) do
        PSClientMessage.hex(
          "32 00 00 01 01 a5 98 60 5c 09 e3 da ed 2e 1f fc 41 a7 7e 22 "\
          "25 00 01 00 02 ff 24 00 00 10 00 a1 b8 45 da 5c 19 7a 80 d9 "\
          "4e 5e 5f 7a 13 46 ff 10 00 00 00 00 00 00 00 00 00 00 00 00 "\
          "00 00 00 00 02 00 00 01 03 07 00 00 00"
        )
      end

      let(:client_message) { PSClientMessage.hex("3200000101a598605c09e3daed2e1ffc41a77e222500010002ff2400001000a1b845da5c197a80d94e5e5f7a1346ff1000000000000000000000000000000000020000010307000000") }

      let(:expected_time)      { PSClientMessage.hex("a5 98 60 5c") }
      let(:expected_challenge) { PSClientMessage.hex("09 e3 da ed 2e 1f fc 41 a7 7e 22 25") }
      let(:expected_p)         { PSClientMessage.hex("a1 b8 45 da 5c 19 7a 80 d9 4e 5e 5f 7a 13 46 ff") }
      let(:expected_g)         { PSClientMessage.hex("00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02") }

      it "works" do
        connection = double(Socket::UDPSource)
        allow(connection).to receive_message_chain(:remote_address, :ip_unpack).and_return(["127.0.0.1", 51_111])
        allow(connection).to receive(:reply).and_return(true)

        session = PSEmu.sessions.find_or_create!(connection)
        server  = PSEmu::Server.new

        expect_packet = lambda do |packet|
          expect(packet[:client_time].bytes).to eq(expected_time.bytes)
          expect(packet[:p_len].to_hex.to_base16).to eq(0x1000)
          expect(packet[:p].bytes).to eq(expected_p.bytes)
          expect(packet[:g_len].to_hex.to_base16).to eq(0x1000)
          expect(packet[:g].bytes).to eq(expected_g.bytes)
        end

        expect_session = lambda do |my_session|
          expect(my_session.server_time.to_byte_string.bytes).to eq(expected_time.bytes)
          expect(my_session.server_pub_key).to be_present
        end

        expect(session).to receive(:generate_dh_key_pairs!).with(expect_packet).and_call_original
        expect(ServerChallengeXChg).to receive(:decode).with(expect_session).and_call_original

        server.process_non_control_packet(session, client_message.message_io)
      end

      it "encodes" do
        expected_res = hex_to_bytes("0201962D84531B0E6408CD935EC2429A EB58000103070000000C00100051F83C E645E86C3E79C8FC70F6DDF14B0E")

        unk0 = 2
        unk1 = 1
        org_time = 0x53842D96
        serverTime = 0x962D8453  # 0x53842D96
        challenge = [ 0x1B, 0x0E, 0x64, 0x08, 0xCD, 0x93, 0x5E, 0xC2, 0x42, 0x9A, 0xEB, 0x58 ]
        unkChallengeEnd = 0
        unkObjects = 1
        unk2 = [ 0x03, 0x07, 0x00, 0x00, 0x00, 0x0C, 0x00 ]
        pubKeyLen = [16, 0x00]
        pubKey = [ 0x51, 0xF8, 0x3C, 0xE6, 0x45, 0xE8, 0x6C, 0x3E, 0x79, 0xC8, 0xFC, 0x70, 0xF6, 0xDD, 0xF1, 0x4B ]
        unk3 = 14

        message = StringIO.new.tap(&:binmode)

        res = [
            unk0, unk1, serverTime, challenge, unkChallengeEnd, unkObjects, unk2, pubKeyLen, pubKey, unk3
        ].to_byte_string



        puts "#{expected_res}"
        puts "#{res.bytes}"

        expect(res.bytes).to eq(expected_res)

      end

      it "works too" do
        expected_res = hex_to_bytes "000200261E2751BDC1CE000000000001D300000002"
        message = StringIO.new(expected_res.to_byte_string).tap(&:binmode)

        Maybe = Struct.new(:message) do
          def read_bytes(size)
            message.read(size)
          end
        end

        expect(SecureRandom).to receive_message_chain(:bytes, :to_hex).and_return("51bdc1ce")

        a = ClientServerStart.decode_and_encode(Maybe.new(message))


        expect(expected_res).to eq(a.bytes)
      end

      def hex_to_bytes(hex_str)
        first_digit_filled = false
        cur_value = 0
        hex_str.each_char.with_object([]) do |c, bytes|
          next if c.match?(/\H/)
          hex = c.hex

          if first_digit_filled
            bytes << (cur_value + hex)
            cur_value = 0
            first_digit_filled = false
          else
            cur_value = 16 * hex
            first_digit_filled = true
          end
        end
      end
    end
  end
end
