# frozen_string_literal: true

module PSEmu
  RSpec.describe ClientServerStart do
    let(:expected_response) { "000200261E2751BDC1CE000000000001D300000002".to_byte_string }
    let(:client_message) do
      PSClientMessage.hex("00010000000200261E27000001F0").tap do |msg|
        msg.pos += 2 #skip initial header byte
      end
    end

    it "successfully extracts and encodes a proper response" do
      expect(SecureRandom).to receive_message_chain(:bytes, :to_hex).and_return(0xCEC1BD51.to_little_i)

      server_response = described_class.decode_and_encode(client_message)
      expect(server_response).to eq(expected_response)
    end
  end
end
