require 'socket'
require 'date'
require 'json-prettyprint'

module LogSimulator
  class PeakLogSimulator

    def self.start(socket,filepath,timescale,pretty)
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
            puts '<' + (pretty ? (JSON::PrettyPrint.prettify(message)) : message)
            time = _time
          end
        end
      end

      yield true
    end

    def self.timestamp_parse (line)
      line.encode!('UTF-8', :undef => :replace, :invalid => :replace, :replace => '') #Fixes for non-utf chars
      line.scan(/N\|(.+)\|RECEIVE << (.*)/) do |timestamp,message|
        begin
          date = DateTime.parse(timestamp)
          yield date.to_time.utc.to_i,message
        rescue
          yield timestamp.to_i,message
        end
      end
    end

  end
end