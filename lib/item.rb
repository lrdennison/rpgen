module Rpgen

  class Item
    attr_accessor :rule
    attr_accessor :dot
    attr_accessor :is_core

    def initialize rule
      @rule = rule
      @dot = 0
      @is_core = false
    end

    def name
      @rule.name
    end

    def at_dot
      if @dot >= @rule.components.count then
        return nil
      end

      return @rule.components[@dot]
    end
    
    def matches sym
      return sym==at_dot()
    end

    def to_s
      s = "#{@rule.name} =>"
      dotted = false
      @rule.components.each_with_index do |sym, ix|
        if ix==@dot then
          s += " <dot>"
          dotted = true
        end
        s += " #{sym}"
      end
      if not dotted then
        s += " <dot>"
      end
      return s
    end
    
    def compare other
      return -1 if rule.number < other.rule.number
      return  1 if rule.number > other.rule.number

      return dot <=> other.dot
    end
    
  end


end
