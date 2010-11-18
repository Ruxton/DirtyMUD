module Dirtymud
  class NPC < Entity
    attr_accessor :id, :name

    def initialize(attrs)
      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end

      super(attrs)
    end
  end
end
