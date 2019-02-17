# frozen_string_literal: true

require "ps_emu"

class LoginServer
  attr_reader :host, :port, :server

  def initialize(host, port)
    @host   = host
    @port   = port
    @server = PSEmu::Server.new
  end

  def call
    Socket.udp_server_loop(host, port) do |message, client_endpoint|
      session = PSEmu.sessions.find_or_create!(client_endpoint)
      File.open("record2.txt", "a+") do |file|
        msg = "[#{message.bytes.join(", ")}]"
        file.puts "[#{message.bytes.join(", ")}]"
        file.puts "................."
        puts "Received: #{msg}"
        puts "..............."
      end
      server.process_packet!(session, message)
    end
  end
end

# f = Thread.new { LoginServer.new("127.0.0.1", 51_000).call }

LoginServer.new("192.168.1.4", 51_201).call

# socket = UDPSocket.new
# socket.bind("127.0.0.1", 52_222)
#
# begin
#   socket.send("hello", 0, "127.0.0.1", 51_000)
#   message = socket.recvfrom(200).first
#   pp message
#   socket.send(message, 0, "127.0.0.1", 51_000)
#   message = socket.recvfrom(200).first
#   pp message
# ensure
#   f.exit
#   socket.close
# end
