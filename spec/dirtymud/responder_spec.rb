require 'spec_helper'

class RespondingObj
  include Dirtymud::Responder
  def event_test(args)
  end
end

require 'observer'
class ObservableObj
  include Observable
end

describe Dirtymud::Responder do
  let(:responder) { RespondingObj.new }
  let(:observed) { ObservableObj.new }

  describe '#update(event_name, args)' do
    it 'invokes event_+event_name+(+args+) on this object' do
      args = {:some_arg => true}
      responder.should_receive(:event_test).with(args)
      responder.update('test', args)
    end
  end

  describe '#observe(obj, do_observe)' do
    context 'when do_observe is ommited or true' do
      it 'adds this object to the target object\'s list of observers' do
        observed.should_receive(:add_observer).with(responder).exactly(2).times
        responder.observe(observed)
        responder.observe(observed, true)
      end
    end

    context 'when do_observe is false' do
      it 'removes this object from the target object\'s list of observers' do
        observed.should_receive(:delete_observer).with(responder)
        responder.observe(observed, false)
      end
    end
  end
end
