module Rpgen

  class Item
    attr_accessor :rule
    attr_accessor :dot

    attr_accessor :grammar
    attr_accessor :is_core

    def initialize rule
      @rule = rule
      @dot = 0
      @is_core = false
    end

    def name
      @rule.name
    end

    # Head seems to be used in the literature
    def head
      @rule.name
    end

    def count
      @rule.components.count
    end

    def at pos
      if pos >= @rule.components.count then
        return nil
      end

      return @rule.components[pos]
    end
    
    def at_dot
      return at(@dot)
    end

    def is_starting_item
      dot==0
    end
    
    def matches sym
      return sym==at_dot()
    end

    def to_s
      s = "#{@rule.name} =>"
      dotted = false
      @rule.components.each_with_index do |sym, ix|
        if ix==@dot then
          s += " &bull;"
          dotted = true
        end
        s += " #{sym}"
      end
      if not dotted then
        s += " &bull;"
      end
      return s
    end
    
    def compare other
      return -1 if rule.number < other.rule.number
      return  1 if rule.number > other.rule.number

      return dot <=> other.dot
    end

    def first pos
      
      if pos>=count then
        return [Rpgen::empty]
      end

      set = grammar.first[at(pos)]
      if set.include?( Rpgen::empty) then
        set = set.delete( Rpgen::empty)
        set = set.union( first(pos+1))
      end

      return set
    end
    
  end


end
