# frozen_string_literal: true

module PSEmu
  class SessionManager
    attr_accessor :sessions

    def initialize
      @sessions = {}
    end

    def find_or_create!(client_endpoint)
      key = session_key(client_endpoint)
      return sessions[key] if sessions.key?(key)

      sessions[key] = SessionPlayer.new(client_endpoint)
    end

    private

    def session_key(client_endpoint)
      client_endpoint.remote_address.ip_unpack.join(":")
    end
  end
end
