require 'observer'

module Dirtymud
  class Server
    include Observable

    attr_accessor :players_by_connection, :players_by_name, :rooms, :starting_room, :items, :npcs, :fights

    def initialize
      @unauthed_users = {}
      @players_by_connection = {}
      @players_by_name=  {}
      @rooms = {}
      @items = {}
      @npcs = {}
      @fights = []
      load_items!
      load_rooms!
    end

    def log(msg)
      puts "[#{Time::now}] #{msg}"
    end

    def input_received!(from_connection, input)
      #is this connection unauthed?
      if @unauthed_users.has_key?(from_connection)
        con_state = @unauthed_users[from_connection]
        if con_state[:name].nil?
          con_state[:name] = input.chomp
          from_connection.write "#{I18n::translate "server.ask.character_password"}"
        elsif con_state[:password].nil?
          con_state[:password] = input.chomp
          #TODO: verify password at some point
          from_connection.write("Welcome, #{con_state[:name]}.\n\n")
          player = player_connected!(from_connection, :name => con_state[:name])
        end
      else
        do_command(from_connection,input)
      end
    end

    def do_command(connection,input)
      case input
      when /^who$/ then players_online(connection)
      else @players_by_connection[connection].send(:do_command, input)
      end
    end

    def players_online(connection)
      output = "Current players online: "
      @players_by_connection.each do |player|
        output += "#{player.name}"
      end
      @players_by_connection[connection].send(:promptannounce, output)
    end

    def welcome_message(connection)
      file = File.expand_path('../../../world/welcome.txt', __FILE__)
      welcome_contents = File.read(file)
      connection.write(welcome_contents)
    end

    def user_connected!(connection)
      @unauthed_users[connection] = {}
      welcome_message(connection)
      connection.write "#{I18n::translate "server.ask.character_name"}"
    end

    def player_connected!(connection, params = {})
      player = Player.new(:name => params[:name], :connection => connection, :server => self)
      @players_by_connection[connection] = player
      @players_by_name[player.name.downcase] = player

      @unauthed_users.delete(connection) #TODO test this
      
      @starting_room.enter(player)
      player.promptannounce(@starting_room.look_str(player))
      log "#{player.name} has joined the server."

      player
    end

    def announce(message, options = {})
      players = options.has_key?(:only) ? options[:only] : @players_by_connection.values
      players = players.reject {|p| options[:except].include?(p)} if options.has_key?(:except)

      players.each do |player|
        player.announce("#{message}")
      end
    end

    def load_rooms!
      yaml = YAML.load_file(File.expand_path('../../../world/rooms.yml', __FILE__))['world']

      # First pass loads all the rooms
      yaml['rooms'].each do |room|
        @rooms[room['id']] = Room.new(
          :id => room['id'],
          :description => room['description'],
          :exits => {}, 
          :server => self)

        #add items to this room
        if room.has_key?('items')
          room['items'].each { |item_id| @rooms[room['id']].items << @items[item_id].clone }
        end
      end

      # Second pass creates exit-links
      yaml['rooms'].each do |room|
        room['exits'].each do |d, id|
          @rooms[room['id']].exits[d.to_sym] = @rooms[id]
        end
      end

      @starting_room = @rooms[yaml['starting_room']]
    end

    def load_items!
      items = YAML.load_file(File.expand_path('../../../world/items.yml', __FILE__))['items']
      items.each do |item|
        @items[item['id']] = Dirtymud::Item.new(:id => item['id'], :name => item['name'])
      end
    end

    def load_npcs!
      npcs = YAML.load_file(File.expand_path('../../../world/npcs.yml', __FILE__))['npcs']
      npcs.each do |npc|
        @npcs[npc['id']] = Dirtymud::NPC.new({
          :server => self,
          :id => npc['id'], 
          :name => npc['name'],
          :melee_damage_per_hit => npc['melee_damage_per_hit'],
          :hit_points => npc['hit_points'] })
      end
    end

    def tick!
      changed
      notify_observers('tick')
    end
  end
end
