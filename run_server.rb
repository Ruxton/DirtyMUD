require 'rubygems'
require 'bundler/setup'
require 'eventmachine'
require 'lib/dirtymud'
require 'i18n'


module Dirtymud
  module EventMachineServer
    def post_init
      #manage all connected clients
      @identifier = self.object_id

      $server.user_connected!(self)

      Dir.glob("config/i18n/*.yml").each do |locale|
        I18n.load_path << locale
      end

    end

    def receive_data(data)
      $server.input_received!(self, data.chomp)

      close_connection if data =~ /quit|exit/i
    end

    def unbind
    end

    def write(data)
      send_data(data)
    end
  end
end

$server = Dirtymud::Server.new

puts "Server running on 127.0.0.1 4000"

EventMachine::run {
  EventMachine::start_server "0.0.0.0", 4000, Dirtymud::EventMachineServer
}

