module Dirtymud
  class Fight
    include Responder

    attr_accessor :fighters

    def initialize(server, fighter_1, fighter_2)
      @fighters = [fighter_1, fighter_2]
      observe(server)
    end

    def event_tick
      @fighters[0].attack!(@fighters[1])
      @fighters[1].attack!(@fighters[0])
    end
  end
end
