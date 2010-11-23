require File.dirname(__FILE__) + '/../spec_helper'

describe Dirtymud::Room do

  describe 'a room' do
    before do
      @server = mock(Dirtymud::Server).as_null_object
      @room = Dirtymud::Room.new(:description => 'Simple room.', :server => @server, :id => '1')
      @room2 = Dirtymud::Room.new(:description => 'Room 2', :server => @server, :id => '2')
      @player = Dirtymud::Player.new(:name => 'Dirk', :server => @server)
      @player2 = Dirtymud::Player.new(:name => 'Alice', :server => @server)
      @player3 = Dirtymud::Player.new(:name => 'Bob', :server => @server)

      #setup exits
      @room.exits[:n] = @room2
      @room2.exits[:s] = @room
    end

    it 'has a description' do
      @room.description.should == 'Simple room.'
    end

    it 'has players' do
      @room.players.should == []
      @room.players.push(@player)
      @room.players.should include(@player)
    end

    it 'has exits' do
      @room.exits[:n].should == @room2
      @room2.exits[:s].should == @room
      @room.exits[:e].should be_nil
    end

    describe '#enter(player)' do
      it 'moves the player into the room' do
        @player.room = @room2
        @room2.players = [@player]
        @room.players = []

        @room2.leave(@player)
        @room2.players.should be_empty
        @room.enter(@player)
        @player.room.should == @room
        @room.players.should include(@player)
      end

      it 'announces the player entry to the room' do
        @room.should_receive(:announce).with("#{@player.name} has entered the room.", {:except => [@player]})
        @player.room = @room2
        @room.enter(@player)
      end
    end

    describe '#leave(player)' do
      it 'announces the player departure to the room' do
        @room2.should_receive(:announce).with("#{@player.name} has left the room.", {:except => [@player]})
        @player.room = @room2
        @room2.leave(@player)
      end

      it 'removes the player from the room' do
        @player.room = @room2
        @room2.players = [@player]
        @room2.leave(@player)
        @room2.players.should be_empty
      end
    end

    describe '#announce' do
      before do
        @server = mock(Dirtymud::Server).as_null_object
        @connection1 = mock(EventMachine::Connection).as_null_object
        @connection2 = mock(EventMachine::Connection).as_null_object
        @connection3 = mock(EventMachine::Connection).as_null_object
        @player1 = @server.player_connected!(@connection1)
        @player2 = @server.player_connected!(@connection2)
        @player3 = @server.player_connected!(@connection3)
        @room = Dirtymud::Room.new(:description => 'Simple room.', :server => @server, :players => [ @player1, @player2, @player3 ])
      end

      it 'calls server#announce to everyone in the room' do
        @server.should_receive(:announce).with("Important message", :only => @room.players)
        @room.announce("Important message")
      end
    end
    
    describe "#do_command" do
    
      before do
        @server = mock(Dirtymud::Server).as_null_object
        @connection = mock(EventMachine::Connection).as_null_object
        @player = @server.player_connected!(@connection)
        @room_center = Dirtymud::Room.new(:description => 'Room Center', :server => @server)
        @room_n = Dirtymud::Room.new(:description => 'Room North', :server => @server)
        @room_s = Dirtymud::Room.new(:description => 'Room South', :server => @server)
        @room_e = Dirtymud::Room.new(:description => 'Room East', :server => @server)
        @room_w = Dirtymud::Room.new(:description => 'Room West', :server => @server)
        @cellar = Dirtymud::Room.new(:description => 'The Cellar', :server => @server)
        
        @room_w.exits = {:e => @room_center}
        @room_e.exits = {:w => @room_center}
        @room_n.exits = {:s => @room_center}
        @room_s.exits = {:n => @room_center}
        @cellar.exits = {:up => @room_center}
        @room_center.exits = {:n => @room_n, :s => @room_s, :e => @room_e, :w => @room_w, :down => @cellar}        
      end
    
      it 'allows the player to move in any directions defined by the room' do
        #dirs = @room_center.available_exits.split(" ")
        dirs = ["n", "N", "w", "W", "e", "E", "s", "S", "down", "DOWN"]
        dirs.each do |dir| 
          @player.room = @room_center
          @player.should_receive(:go).with(dir.to_s)          
          @room_center.do_command(@player, dir)          
        end
      end

      it 'falls back to player.unknown_input when it has nfi' do
        @player.room = @room_center
        @player.should_receive(:unknown_input)
        @room_center.do_command(@player,"iliketowritethingsthatyoushouldntread")
      end

    end
      

    describe '#exits_str' do
      it 'returns the exit string for this room' do
        @room.exits_str.should == "[Exits: N]"
      end
    end

    describe '#players_str(for_player)' do
      context 'when there is one other player in the room' do
        it 'shows the other player in the room' do
          @room.players = []
          @room.players << @player
          @room.players << @player2
          @room.players_str(@player).should == "\nAlice is here."
        end
      end
    end

    describe '#items_str' do
      context 'when items are in the room' do
        it 'returns a string of all the items in the room' do
          @room.items = [ Dirtymud::Item.new(:name => 'a sword') ]
          @room.items_str.should include('Items here')
          @room.items_str.should include('a sword')
        end
      end

      context 'when there are no items in the room' do
        it 'does not show Items Here' do
          @room.items = []
          @room.items_str.should_not include('Items here')
          @room.items_str.should_not include('a sword')
        end
      end
    end

    describe '#look_str(for_player)' do
      context 'when nobody else is in the room' do
        it 'returns the room description and exits' do
          @room.items << Dirtymud::Item.new(:name => 'a sword')
          @room.look_str(@player1).should include("#{@room.description}")
          @room.look_str(@player1).should include("#{@room.exits_str}")
        end
      end

      context 'when alice is also in the room' do
        it 'shows that player2 is here as well' do
          @room.players = [ @player2 ]
          @room.look_str(@player).should include("#{@player2.name} is here.")
        end
      end
    end

    describe "#inspect" do

      it 'should return a string of the room ID' do
        @room.inspect.should ==  "Room #{@room.id}"
      end

    end

  end

end
