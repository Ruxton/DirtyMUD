module Dirtymud
  class Fight
    attr_accessor :fighters

    def initialize(fighter_1, fighter_2)
      @fighters = [fighter_1, fighter_2]
    end

    def tick!
      @fighters[0].attack!(@fighters[1])
      @fighters[1].attack!(@fighters[0])
    end
  end
end
