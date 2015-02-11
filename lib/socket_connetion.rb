require 'socket'

module LogSimulator
  class SocketConnetion
    attr_reader :socket
    def initialize (host,port)
      begin
        @socket = TCPSocket.new(host,port)
      rescue Exception => _
        @socket = nil
      end
    end
  end
end