# frozen_string_literal: true

module PSEmu
  RSpec.describe Server do

    describe "#process_non_control_packet" do
      let(:connection) { double(Socket::UDPSource) }
      let(:session)    { PSEmu.sessions.find_or_create!(connection) }
      let(:server)     { PSEmu::Server.new }

      subject(:described_method) { server.process_non_control_packet(session, client_message.message_io) }

      before do
        allow(connection).to receive_message_chain(:remote_address, :ip_unpack).and_return(["127.0.0.1", 51_111])
        allow(connection).to receive(:reply).and_return(true)
      end

      context "when the client is establishing crypto session" do
        let(:client_message) do
          PSClientMessage.hex(
              "32 00 00"\
              "0101962D845324F5997CC7D16031D1F5 "\
              "67E900010002FF2400001000F57511EB "\
              "8E5D1EFB8B7F3287D5A18B1710000000 "\
              "00000000000000000000000000020000 "\
              "010307000000"
          )
        end

        it "decodes the clients message" do
          expect_decoding = lambda do |packet|
            expect(packet[:client_time]).to eq(0x53842D96)
            expect(packet[:challenge]).to eq("24F5997CC7D16031D1F567E9".to_byte_string)

            expect(packet[:p_len]).to eq(0x0010)
            expect(packet[:p]).to eq("F57511EB8E5D1EFB8B7F3287D5A18B17".to_byte_string)

            expect(packet[:g_len]).to eq(0x0010)
            expect(packet[:g]).to eq("00000000000000000000000000000002".to_byte_string)
          end

          expect(session).to receive(:generate_dh_key_pairs!).with(expect_decoding).and_call_original
          described_method
        end

        it "stores server information on the players session" do
          expect_session = lambda do |my_session|
            expect(my_session.server_time.to_byte_string.bytes).to eq(expected_time.bytes)
            expect(my_session.server_pub_key).to be_present
          end

          expect(ServerChallengeXChg).to receive(:decode).with(expect_session).and_call_original
          described_method
        end

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
