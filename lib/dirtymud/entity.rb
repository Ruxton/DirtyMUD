module Dirtymud
  class Entity
    include Dirtymud::Responder
    
    attr_accessor :hit_points, :name, :room, :items, :server, :melee_damage_per_hit

    def initialize(attrs)
      #we expec these required attrs
      @hit_points = attrs[:hit_points]
      @melee_damage_per_hit = attrs[:melee_damage_per_hit]
      @name = attrs[:name]

      #set any non-required attrs passed
      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end
      
      @items ||= []

      #listen for events from the server
      observe(attrs[:server])
    end

    def event_tick(args={})
      regen
    end

    def regen
    end

    def attack!(target)
      target.hit_points -= @melee_damage_per_hit
    end
  end
end
