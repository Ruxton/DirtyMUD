module Dirtymud
  class Entity
    attr_accessor :hit_points, :name, :room, :items

    def initialize(attrs)
      #we expec these required attrs
      @hit_points = attrs[:hit_points]
      @name = attrs[:name]

      #set any non-required attrs passed
      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end
      
      @items ||= []
    end
  end
end
