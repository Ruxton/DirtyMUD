module Dirtymud
  class Fight
    include Responder

    attr_accessor :fighters

    def initialize(server, fighter_1, fighter_2)
      @fighters = [fighter_1, fighter_2]
      @is_over = false
      @server = server
      @server.fights << self
      observe(@server)
    end

    def ended?
      @is_over
    end

    def end_fight!
      @is_over = true
      @server.fights.delete(self)
      observe(@server, false)
    end

    def event_tick
      #let each fighter do some damage if he's still alive
      should_end = false
      if @fighters[0].hit_points > 0
        @fighters[0].attack!(@fighters[1]) 
      else
        should_end = true
      end

      if !should_end && @fighters[1].hit_points > 0
        @fighters[1].attack!(@fighters[0]) 
      else
        should_end = true
      end

      #end this fight if either of the fighters droped below 0 HPs
      end_fight! if should_end
    end
  end
end
