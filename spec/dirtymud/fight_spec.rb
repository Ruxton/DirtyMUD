require 'spec_helper'

module Dirtymud
  describe Fight do
    before do
      @server = mock(Server).as_null_object
      @player = Dirtymud::Player.new(:name => 'Dirk', :connection => mock(EventMachine::Connection).as_null_object, :room => mock(Room), :server => @server, :hit_points => 10)
      @mob = Dirtymud::NPC.new(:name => 'a bunny', :hit_points => 10, :room => mock(Room), :server => @server)
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
    end
  end
end
