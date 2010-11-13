require 'spec_helper'

describe Dirtymud::Server do
  describe 'a server' do
    before do
      @server = Dirtymud::Server.new
    end

    it 'has a players_by_connection hash' do
      @server.players_by_connection.should be_kind_of(Hash)
    end

    describe '.input_received(from_connection, input)' do
      context 'when a player is connected' do
        @dirk_con = EventMachine::Connection.new(nil)
        @dirk = Dirtymud::Player.new(:name => 'Dirk', :connection => @dirk_con)

        it 'sends the command on to the player instance' do
          @dirk.should_receive(:do_command).with('n')
          @server.input_received(@dirk_con, 'n')
        end
      end
    end

    describe 'loading rooms from a yml file' do
      before :each do
        yaml = { 'world' => { 'starting_room' => 1, 'rooms' => [
          { 'id' => 1, 'description' => "booyah", 'exits' => { 'n' => 2 } },
          { 'id' => 2, 'description' => "yahboo", 'exits' => { 's' => 1 } }
        ] } }
        YAML.should_receive(:load_file).with(File.expand_path('../../../world/rooms.yml', __FILE__)).and_return(yaml)
        @server.load_rooms
      end
      it 'should create room definitions' do
        @server.rooms[1].id.should == 1
        @server.rooms[1].description.should == 'booyah'
        @server.rooms[1].exits[:n].description.should == 'yahboo'
      end

      it 'should set the starting_room' do
        @server.starting_room.should == @server.rooms[1]
      end
    end

  end
end
