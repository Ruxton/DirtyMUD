require 'spec_helper'

describe Dirtymud::Entity do
  describe 'An entity' do
    let(:entity){ Dirtymud::Entity.new({
      :hit_points => 10,
      :name => 'entity',
      :room => Dirtymud::Room.new({}) }) }
    subject { entity }

    its(:hit_points) { should be_integer }
    its(:name) { should be_a_kind_of(String) }
    its(:room) { should be_a_kind_of(Dirtymud::Room) }
    its(:items) { should be_a_kind_of(Array) }
  end
end
