require 'spec_helper'

module Dirtymud
  describe Fight do
    before do
      @server = Server.new
      @player = Dirtymud::Player.new(:name => 'Dirk', :connection => mock(EventMachine::Connection).as_null_object, :room => mock(Room), :server => @server, :hit_points => 10, :melee_damage_per_hit => 3)
      @mob = Dirtymud::NPC.new(:name => 'a bunny', :hit_points => 10, :room => mock(Room), :server => @server, :melee_damage_per_hit => 1)
      @fight = Fight.new(@server, @player, @mob)
    end

    describe '#initialize(server, fighter_1, fighter_2)' do
      it 'adds the fighters passed in to @fighters[] in order' do
        @fight = Fight.new(@server, 1, 2)
        @fight.fighters.should == [1, 2]
      end

      it 'defaults to not being over' do
        @fight.ended?.should be_false
      end

      it 'adds itself to the server\'s list of fights' do
        @server.fights.should include(@fight)
      end
    end

    describe '#fighters' do
      it 'returns an array of the fighters in this fight' do
        @fight.fighters.should == [@player, @mob]
      end
    end

    describe '#end_fight!' do
      it 'ends the fight' do
        @fight.ended?.should be_false
        @fight.end_fight!
        @fight.ended?.should be_true
      end

      it 'removes the fight from the server\'s @fights array' do
        @server.fights.should include(@fight)
        @fight.end_fight!
        @server.fights.should_not include(@fight)
      end

      it 'stops listening to events from the server' do
        @fight.should_receive(:observe).with(@server, false)
        @fight.end_fight!
      end
    end

    describe '#ended?' do
      it 'returns true when the fight is over' do
        @fight.ended?.should be_false
        @fight.end_fight!
        @fight.ended?.should be_true
      end
    end

    describe '#event_tick' do
      it 'calls #attack(target) on each fighter (in the order they exist in the @fighters array), passing in the other member of the fight as the target of the attack ' do
        @player.should_receive(:attack!).with(@mob).exactly(1).times
        @mob.should_receive(:attack!).with(@player).exactly(1).times
        @fight.event_tick
      end

      context 'when either player drops to 0 or lower hit points' do
        it 'calls #end_fight!' do
          @fight.should_receive(:end_fight!)
          @player.hit_points = 0
          @fight.event_tick
        end
      end
    end
  end
end
