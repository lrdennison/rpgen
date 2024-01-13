module Rpgen

  class Item
    attr_accessor :rule
    attr_accessor :dot
    attr_accessor :follows
    
    attr_accessor :parent       # Item Set
    
    attr_accessor :grammar
    attr_accessor :is_core

    attr_accessor :modified
    
    def initialize rule
      @rule = rule
      @dot = 0
      @is_core = false
      @follows = UniqueArray.new
      @parent = nil
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

    # Used for simpler equivalence checking
    def uid
      return @rule.number*1024 + @dot
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

    def post_dot
      a = []
      x = @dot+1
      while x < count do
        a.push(at(x))
        x += 1
      end
      return a
    end
    
    def is_starting_item
      dot==0
    end
    
    def matches sym
      return sym==at_dot()
    end

    def merge other
      if rule != other.rule then
        raise "Attempting to merge incompatible items"
      end
      
      if dot != other.dot then
        raise "Attempting to merge incompatible items"
      end

      @modified = @follows.merge!( other.follows)

      return @modified
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

      # s += ", ["
      # s += follows.join( "/")
      # s += "]"
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
