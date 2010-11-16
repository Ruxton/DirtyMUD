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
        promptannounce("You can't go that way. #{room.exits_str}\n")
      end
    end

    def say(message)
      room.announce("#{name} says '#{message}'", :except => [self])
      promptannounce("You say '#{message}'")
    end

    def get(item_text)
      #try to find an item in this room who's name contains the requested item text
      matches = room.items.select{|i| i.name =~ /#{item_text}/}

      if matches.length > 0
        if matches.length == 1
          item = matches[0]

          #give the item to the player
          items << item
          
          #remove the item from the room
          room.items.delete(item)
          
          #tell the player they got it
          promptannounce("You get #{item.name}")

          #tell everyone else in the room that the player took it
          room.announce("#{self.name} picks up #{item.name}", :except => [self])
        else
          #ask the player to be more specific
          promptannounce("Be more specific. Which did you want to get? #{matches.collect{|i| "'#{i.name}'"}.join(', ')}")
        end
      else
        #tell the player there's nothing here by that name
        promptannounce("There's nothing here that looks like '#{item_text}'")
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
          promptannounce("You drop #{item.name}")

          #tell everyone else in the room that the player took it
          room.announce("#{self.name} drops #{item.name}", :except => [self])
        else
          #ask the player to be more specific
          promptannounce("Be more specific. Which did you want to drop? #{matches.collect{|i| "'#{i.name}'"}.join(', ')}")
        end
      else
        #tell the player there's nothing in their inventory by that name
        promptannounce("There's nothing in your inventory that looks like '#{item_text}'")
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
      str = "Your items:\n"
      if items.length > 0
        items.each { |i| str << "  - #{i.name}\n" }
      else
        str << "  (nothing in your inventory, yet...)"
      end

      promptannounce(str)
    end

    def emote(action)
      room.announce("#{name} #{action}")
    end

    def unknown_input
      announce "have you tied help?!"
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
      when /^help$/ then help
      else unknown_input
      end
    end
  end
end
