require File.dirname(__FILE__) + '/../spec_helper'

describe Dirtymud::Item do
  describe 'an item' do

    before do
      @item = Dirtymud::Item.new(:name => 'sword of a thousand truths', :short_description => 'The sword of a thousand truths', :detailed_description => 'Some longer description here')
    end

    context '#attributes' do
      it 'should have a name' do
        @item.name.should == "sword of a thousand truths"
      end

      it 'should have a short_description' do
        @item.short_description.should == "The sword of a thousand truths"
      end

      it 'should have a detailed_description' do
        @item.detailed_description.should == "Some longer description here"
      end
    end

  end
end
