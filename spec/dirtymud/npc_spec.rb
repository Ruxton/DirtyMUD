require 'spec_helper'

describe Dirtymud::NPC do
  describe 'an NPC' do
    let(:npc) { Dirtymud::NPC.new(:server => Dirtymud::Server.new, :name => 'bunny rabbit', :hit_points => 10) }
    subject { npc }

    its('class.superclass'){ should == Dirtymud::Entity }
  end
end
