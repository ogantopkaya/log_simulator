#!/usr/bin/env ruby

require 'dnssd'
require 'socket'

module LogSimulator
  class Target
    attr_accessor :name,:target_name,:port

    def initialize(name,target_name,port)
      @name = name
      @target_name = target_name
      @port = port
    end

    def eql?(o)
      self == o
    end

    def ==(o)
      o.class == self.class && o.target_name == @target_name && o.port == @port
    end

    def hash
      @target_name.hash
    end
  end

  class Resolver
    def self.select_target(scan_time)
      self.resolve_service(scan_time) do |found_targets|
        if found_targets.count <= 0
          puts 'no possible target found!'
        elsif found_targets.count == 1
          target = found_targets[0]
          yield target
        else
          puts 'Which one to connect?'
          found_targets.each_with_index do |target,index|
            puts "#{index+1}. #{target.name} - #{target.target_name}: #{target.port}"
          end

          puts 'Select: '
          selection = gets.chomp.to_i - 1
          while(selection < 0 || selection >= found_targets.count)
            puts "Select between #{0}-#{found_targets.count}"
            selection = gets.chomp.to_i - 1
          end
          yield found_targets[selection]
        end
      end
    end

    def self.resolve_service(scan_time)
      browser = DNSSD::Service.new
      service_name = '_debugConnection._tcp'
      puts "Browsing for #{service_name}"

      found_targets = []
      Thread.new do
        browser.browse service_name do |reply|
          Thread.new do
            Thread.exclusive do
              resolver = DNSSD::Service.new
              resolver.resolve reply do |r|
                found_targets<<Target.new(r.name,r.target,r.port)
                break unless r.flags.more_coming?
              end
            end
          end
        end
      end
      sleep scan_time
      found_targets.uniq!
      yield found_targets
    end
  end
end
