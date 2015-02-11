require 'socket'

module LogSimulator
  class PeakLogSimulator

    def self.start(socket,filepath,timescale)
      path = File.expand_path(filepath)
      puts 'Opening log file at path: ' + path

      unless File.exist? path
        puts 'No such file at path '+ path
        yield false
        return
      end

      time = 0
      File.open(path,'r+:utf-8') do |file|
        file.each_line do |line|
          timestamp_parse(line) do |_time,message|
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

      yield true
    end

    def self.timestamp_parse (line)
      line.scan(/N\|(\d+)\|RECEIVE << (.*)/) do |timeStr,message|
        yield timeStr.to_i,message
      end
    end

  end
end