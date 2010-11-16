module Dirtymud
  class Player
    attr_accessor :name, :room, :connection, :items

    def initialize(attrs)
      @prompt = "> "
      @items = []
      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end
    end

    def prompt
      @prompt
    end

    def announce(msg)
      connection.write(msg)
    end
    
    def promptannounce(msg)
      if !msg.end_with?("\n")
        msg = msg + "\n"
      end
      connection.write(msg)
      connection.write(@prompt)
    end

    def send_data(data)
      connection.write(data)
    end

    def go(dir)
      #find out what room to go to
      if room.exits[dir.to_sym]
        # switch rooms
        room.leave(self)
        new_room = room.exits[dir.to_sym]
        new_room.enter(self)

        # send the new room look to the player
        promptannounce(new_room.look_str(self))
      else
        promptannounce("#{I18n::translate "player.go.deny"} #{room.exits_str}\n")
      end
    end

    def say(message)
      room.announce("#{name} #{I18n::translate "room.announce.say"} '#{message}'", :except => [self])
      promptannounce("#{I18n::translate "player.say"} '#{message}'")
    end

    def get(item_text)
      #try to find an item in this room who's name contains the requested item text
      matches = room.items.select{|i| i.name =~ /#{item_text}/}

      if matches.length > 0
        if matches.length == 1
          item = matches[0]

          #give th  e item to the player
          items << item
          
          #remove the item from the room
          room.items.delete(item)
          
          #tell the player they got it
          promptannounce("#{I18n::translate "player.get.self"} #{item.name}")

          #tell everyone else in the room that the player took it
          room.announce("#{self.name} #{I18n::translate "room.announce.get"} #{item.name}", :except => [self])
        else
          #ask the player to be more specific
          promptannounce("#{I18n::translate "player.get.many"} #{matches.collect{|i| "'#{i.name}'"}.join(', ')}")
        end
      else
        #tell the player there's nothing here by that name
        promptannounce("#{I18n::translate "player.get.none"} '#{item_text}'")
      end
    end

    def drop(item_text)
      #try to find an item in this room who's name contains the requested item text
      matches = items.select{|i| i.name =~ /#{item_text}/}

      if matches.length > 0
        if matches.length == 1
          item = matches[0]

          #drop the item to the room
          room.items << item
          
          #remove the item from the player
          items.delete(item)

          #tell the player they dropped it
          promptannounce("#{I18n::translate "player.drop.self"} #{item.name}")

          #tell everyone else in the room that the player took it
          room.announce("#{self.name} #{I18n::translate "room.announce.drop"} #{item.name}", :except => [self])
        else
          #ask the player to be more specific
          promptannounce("#{I18n::translate "player.drop.many"} #{matches.collect{|i| "'#{i.name}'"}.join(', ')}")
        end
      else
        #tell the player there's nothing in their inventory by that name
        promptannounce("#{I18n::translate "player.drop.none"} '#{item_text}'")
      end
    end

    def help
      help_contents = File.read(File.expand_path('../../../world/help.txt', __FILE__))
      promptannounce(help_contents)
    end

    def look
      promptannounce(room.look_str(self))
    end

    def inventory
      str = I18n::translate("player.inventory.pre")+"\n"
      if items.length > 0
        items.each { |i| str << "  - #{i.name}\n" }
      else
        str << I18n::translate("player.inventory.zero")+"\n"
      end

      promptannounce(str)
    end

    def emote(action)
      room.announce("#{name} #{action}")
    end

    def unknown_input
      promptannounce I18n::translate("player.unknown_input")
    end

    def do_command(input)
      case input
      when /^[nesw]$/ then go(input)
      when /^say (.+)$/ then say($1)
      when /^get (.+)$/ then get($1)
      when /^drop (.+)$/ then drop($1)
      when /^(i|inv|inventory)$/ then inventory
      when /^(l|look)$/ then look
      when /^\/me (.+)$$/ then emote($1)
      when /^\?|help$/ then help
      when /^(.)+$$/ then unknown_input
      else look
      end
    end
  end
end
