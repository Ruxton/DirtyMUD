require 'spec_helper'

module Dirtymud
  describe Entity do
    describe 'An entity' do
      before do
        @server = Dirtymud::Server.new 
        @entity_attrs = {
          :server => @server,
          :hit_points => 10,
          :name => 'entity',
          :melee_damage_per_hit => 3,
          :room => Dirtymud::Room.new({})
        }
        @entity = Dirtymud::Entity.new(@entity_attrs)
      end

      let(:entity) { Dirtymud::Entity.new(@entity_attrs) }

      subject { entity }

      its(:hit_points) { should be_integer }
      its(:name) { should be_a_kind_of(String) }
      its(:room) { should be_a_kind_of(Dirtymud::Room) }
      its(:items) { should be_a_kind_of(Array) }
      its(:melee_damage_per_hit) { should be_a_kind_of(Integer) }

      describe '#attack!(target)' do
        it 'takes @melee_damage_per_hit off of target\'s hit_points' do
          target = Entity.new(@entity_attrs.merge({ :hit_points => 5 }))
          @entity.melee_damage_per_hit = 3
          @entity.attack!(target)
          target.hit_points.should == 2
        end
      end

      it 'listens to server ticks when it is created' #how to test this because i want to test something in an initializer so how can i pass the expectation of this instance to server.should_recieve(:add_observer).with(entity) when i dont have a handle on the entity until i create it?

      #-----------------------------------------------
      # Events
      #-----------------------------------------------
      describe '#event_tick' do
        it 'regens' do
          @entity.should_receive(:regen)
          @entity.event_tick
        end
      end
    end
  end
end
