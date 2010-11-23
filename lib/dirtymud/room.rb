module Dirtymud
  class Room
    attr_accessor :id, :description, :players, :exits, :server, :items

    def initialize(attrs)
      @players = []
      @exits = {}
      @items = []

      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end
    end

    def enter(player)
      player.room = self
      players.push(player)
      # announce to other players that they've entered the room
      announce("#{player.name} #{I18n::translate "room.announce.enter"}", :except => [player])
    end

    def leave(player)
      players.delete(player)
      # announce to other players that they've left the room
      announce("#{player.name} #{I18n::translate "room.announce.leave"}", :except => [player])
    end

    def announce(message, options = {})
      server.announce(message, options.merge(:only => players))
    end

    def available_exits
      exits.collect{|dir, room| dir.to_s.downcase+' '+dir.to_s.upcase}.join(' ')
    end

    def exits_str
      dirs = exits.collect{|dir, room| dir.to_s.upcase}.join(', ')
      "[Exits: #{dirs}]"
    end

    def players_str(for_player) 
      other_players = players.reject{|p| p == for_player}
      str = "\n"
      other_players.each { |p| str << "#{p.name} is here." }
      str
   end

    def items_str
      str = ""
      if items.length > 0
        str = "#{I18n::translate "room.items.pre"}\n"
        items.each { |i| str << "  - #{i.name}\n" }
      end

      str
    end

    def look_str(for_player)
      str = ""
      str << description + "\n"
      str << items_str + "\n"
      str << players_str(for_player) + "\n"
      str << exits_str + "\n"      
    end

    def do_command(player,input)
      dirs = self.available_exits + " n e s w N E S W"
      
      dirs = dirs.gsub " ", "|"
      case input
        when /^(#{dirs})$/ then player.go(input)
        else player.unknown_input
      end
    end

    def inspect
      "Room #{id}"
    end
  end
end
