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
