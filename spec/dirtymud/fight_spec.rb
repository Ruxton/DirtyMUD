require 'spec_helper'

module Dirtymud
  describe Fight do
    before do
      @player = mock(Player)
      @mob = mock(NPC)
      @server = mock(Server).as_null_object
      @fight = Fight.new(@server, @player, @mob)
    end

    describe '#initialize(server, fighter_1, fighter_2)' do
      it 'adds the fighters passed in to @fighters[] in order' do
        @fight = Fight.new(@server, 1, 2)
        @fight.fighters.should == [1, 2]
      end
    end

    describe '#fighters' do
      it 'returns an array of the fighters in this fight' do
        @fight.fighters.should == [@player, @mob]
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
