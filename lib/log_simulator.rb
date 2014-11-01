
module LogSimulator
  class PlusLogSimulator

    def self.start(filepath)
      begin
        socket = TCPSocket.new 'localhost',7658
      rescue Exception => _
        socket = nil
      end

      path = File.expand_path(filepath)
      puts "Opening log file at path: " + path

      time = 0
      timescale = 1

      File.open(path,'r+:utf-8') do |file|
        file.each_line do |line|
          line.scan(/N\|(\d+)\|RECEIVE << (.*)/) do |timeStr,message|
            _time = timeStr.to_i
            if time != 0
              sleep (_time - time) * timescale
            end
            if socket != nil
              socket.puts message
            end
            puts '<' + message
            time = _time
          end
        end
      end

    end

  end
end