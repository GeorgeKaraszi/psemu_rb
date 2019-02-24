# frozen_string_literal: true

class PSClientMessage
  attr_accessor :message, :message_io, :original_message

  delegate :to_s, :bytes, to: :message
  delegate_missing_to :message_io

  alias packet message_io
  alias to_byte_string to_s

  def self.hex(message)
    msg = message.dup
    msg = msg.to_byte_string
    new(msg, message)
  end

  def initialize(message, original_message = nil)
    @message          = message
    @message_io       = PSEmu::Server::ClientMessage.new(message)
    @original_message = original_message || message
  end
end

class PSClient
  attr_reader   :host, :port, :socket, :mut_lock, :condition
  attr_accessor :server_thread, :server, :server_client_response

  delegate :close,                to: :socket, allow_nil: true, prefix: :client
  delegate :host, :port, :socket, to: :server, allow_nil: true, prefix: :server

  alias stop_client! client_close

  def initialize(host = "127.0.0.1", port = 52_222, with_server: true)
    @server_thread    = nil
    @server           = nil
    @host             = host
    @port             = port
    @mut_lock         = Mutex.new
    @condition        = ConditionVariable.new
    @socket           = UDPSocket.new
    @socket.bind(@host, @port)

    start_contained_server! if with_server
  end

  def terminate!
    stop_server!
    stop_client!
  end

  def server_client_response!
    wait_for_mutex! if server_client_response.nil?
    server_client_response.tap { @server_client_response = nil }
  end

  def send_to(message, recv_server = server, block: true)
    @socket.send(message.to_s, 0, recv_server.host, recv_server.port)

    wait_for_mutex! if block
  end

  private

  def start_contained_server!(port = 59_999)
    return server_thread unless server_thread.nil?

    @server        = PSEmu::Server.new(host: @host, port: port)
    that           = self
    @server_thread = Thread.new { thread_runner(that) }
  end

  def stop_server!
    if server_thread
      Thread.kill(server_thread)
    elsif server
      server.close!
    end
  end

  def wait_for_mutex!
    mut_lock.synchronize { condition.wait(mut_lock, 20) }
  end

  def thread_runner(that)
    loop do
      that.server_client_response = that.server.call
      that.mut_lock.synchronize { that.condition.signal }
    end
  ensure
    puts "[THREAD] Closing Server!"
    that.server&.close!
  end
end
