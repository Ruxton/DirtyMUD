require File.dirname(__FILE__) + '/../spec_helper'

describe Dirtymud::Server do
  describe 'a server' do
    before { @server = Dirtymud::Server.new }
    subject { @server }
  
    it 'has a players_by_connection hash' do
      @server.players_by_connection.should be_kind_of(Hash)
    end

    it 'has an npcs hash' do 
      @server.npcs.should be_kind_of(Hash)
    end

    it 'has a rooms hash' do 
      @server.rooms.should be_kind_of(Hash)
    end

    specify { subject.fights.should be_kind_of(Array) }

    describe '#initialize' do
      it 'loads the rooms' do
        pending "find out how to test an that an initializer invokes some methods like #load_rooms!"
      end
      it 'loads the items' do
        pending "find out how to test an that an initializer invokes some methods like #load_rooms!"
      end
    end

    describe '#input_received!(from_connection, input)' do
      context 'when a player is connected' do
        it 'sends the command on to the player instance' do
          @dirk_con = EventMachine::Connection.new(nil)
          @dirk = Dirtymud::Player.new(:name => 'Dirk', :connection => @dirk_con, :server => @server)
          @server.players_by_connection[@dirk_con] = @dirk

          @dirk.should_receive(:do_command).with('n')
          @server.input_received!(@dirk_con, 'n')
        end
      end
    end

    describe '#player_connected!(connection)' do
      before do
        @dirk_con = mock(EventMachine::Connection).as_null_object
        @player = Dirtymud::Player.new( :name => 'Dirk', :connection => @dirk_con, :server => @server )
      end
      
      it 'adds a new player to players_by_connection hash' do
        @server.player_connected!(@dirk_con, :name => 'Dirk')        
        @server.players_by_connection[@dirk_con].should be_kind_of(Dirtymud::Player)
      end  

      it 'sends them the initial room description' do
        @dirk_con.should_receive(:write).with("#{@server.starting_room.look_str(@player)}")
        @server.player_connected!(@dirk_con, :name => 'Dirk')
      end
      
      it 'deletes any unauthed users' do
        pending "will work on this soon"
      end

    end

    describe '#user_connected!' do
      before do
        @dirk_con = mock(EventMachine::Connection).as_null_object
      end

      it 'should add you to unauthed users' do
        pending "this limbo is an annoying tests! halp!"
      end
      
      it 'should send you the welcome message' do
        @msg = "Welcome to DirtyMud"
        File.stub!(:read) { @msg }
        @dirk_con.should_receive(:write).with(@msg)
        @server.user_connected!(@dirk_con)
      end
      
      it 'should ask for a character name' do
        @dirk_con.should_receive(:write).with("Enter your character name:")
        @server.user_connected!(@dirk_con)
      end
    end

    describe '#announce' do
      before do
        @connection1 = mock(EventMachine::Connection).as_null_object
        @connection2 = mock(EventMachine::Connection).as_null_object
        @connection3 = mock(EventMachine::Connection).as_null_object
        @player1 = @server.player_connected!(@connection1, :name => 'P1')
        @player2 = @server.player_connected!(@connection2, :name => 'P2')
        @player3 = @server.player_connected!(@connection3, :name => 'P3')
      end
      
      it 'should send a message to all connected players' do
        @connection1.should_receive(:write).with("This is very important")
        @connection2.should_receive(:write).with("This is very important")
        @server.announce("This is very important")
      end

      it 'should allow you to ignore certain players' do
        @connection1.should_not_receive(:write).with("This is very important")
        @connection2.should_receive(:write).with("This is very important")
        @server.announce("This is very important", :except => [@player1])
      end

      it 'should allow you to specify certain players' do
        msg = "This is very important"
        @connection1.should_receive(:write).with(msg)
        @connection3.should_not_receive(:write).with(msg)
        @server.announce("This is very important", :only => [@player1])
      end
    end

    describe '#load_items!' do
      it 'loads the items into the server global items hash' do
        sword = { 'id' => 1, 'name' => "a sword"}
        book = { 'id' => 2, 'name' => "a mysterious book"}
        ring = { 'id' => 3, 'name' => "a ring with a large ruby on it"}
        yaml = { 'items' => [
          sword,
          book,
          ring,
        ] }
        items_by_id = {1 => sword, 2 => book, 3 => ring}
        YAML.should_receive(:load_file).with(File.expand_path('../../../world/items.yml', __FILE__)).and_return(yaml)
        @server.load_items!

        items_by_id.each do |id, item|
          @server.items[id].name.should == item['name']
        end
      end
    end

    describe '#load_rooms!' do
      before :each do
        #rooms support having items in them, so load some items to help test that capability
        items_yaml = {'items' => [
          {'id' => 1, 'name' => 'a sword'}
        ]}
        YAML.should_receive(:load_file).with(File.expand_path('../../../world/items.yml', __FILE__)).and_return(items_yaml)
        @server.load_items!

        rooms_yaml = { 'world' => { 'starting_room' => 1, 'rooms' => [
          { 'id' => 1, 'description' => "booyah", 'exits' => { 'n' => 2 }, 'items' => [1] },
          { 'id' => 2, 'description' => "yahboo", 'exits' => { 's' => 1 } }
        ] } }
        YAML.should_receive(:load_file).with(File.expand_path('../../../world/rooms.yml', __FILE__)).and_return(rooms_yaml)
        @server.load_rooms!
      end

      it 'creates rooms with their starting items too' do
        @server.rooms[1].id.should == 1
        @server.rooms[1].description.should == 'booyah'
        @server.rooms[1].exits[:n].description.should == 'yahboo'
        @server.rooms[1].items[0].should be_kind_of(Dirtymud::Item)
        @server.rooms[1].items[0].name.should == 'a sword'
      end

      it 'sets the starting_room' do
        @server.starting_room.should == @server.rooms[1]
      end
    end

    describe '#load_npcs!' do
      before :each do
        npcs_yaml = {
          'npcs' => [
            {'id' => 1, 'name' => 'bunny rabbit', 'hit_points' => 10, 'melee_damage_per_hit' => 1}
          ]
        }

        #mock out the return value of loading items.yml 
        YAML.should_receive(:load_file).with(File.expand_path('../../../world/npcs.yml', __FILE__)).and_return(npcs_yaml)
        @server.load_npcs!
      end

      it 'populates @npcs with a hash of the npcs, keyed on id' do
        @server.npcs[1].id.should == 1
        @server.npcs[1].name.should == 'bunny rabbit'
        @server.npcs[1].hit_points.should == 10
        @server.npcs[1].melee_damage_per_hit.should == 1
      end
    end

    describe '#tick!' do
      it 'calls notify_observers("tick")' do
        @server.should_receive(:notify_observers).with('tick')
        @server.tick!
      end
    end
  end
end
