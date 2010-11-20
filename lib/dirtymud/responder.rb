#thanks to rubymud for this concept to share the event responding code easily between everything that wants to respond to events
module Dirtymud
  module Responder
    def update(event, args)
      begin
        self.send("event_" + event.to_s, args)
      rescue NoMethodError
        #puts "#{self.class} received an event: #{event.to_s} w/ args: #{args.to_s} that it did not understand."
      end
    end

    #listen to events from an object, or stop listening to events on that object
    def observe(obj, do_observe=true)
      if do_observe
        obj.add_observer(self)
      else
        obj.delete_observer(self)
      end
    end
  end
end
