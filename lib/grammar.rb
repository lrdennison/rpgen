module Rpgen

  def self.eof
    "$".to_sym
  end
  
  def self.start
    "$S".to_sym
  end
  
  def self.empty
    "$e".to_sym
  end
    
  class Component
    attr_accessor :name

    def initialize n=nil
      if n.is_a?(String) then
        n = n.to_sym
      end
      @name = n
    end
  end

  class Terminal < Component
    attr_accessor :is_eof
    attr_accessor :is_empty
    
    def initialize n=nil
      super(n)
      @is_eof = false
      @is_empty = false
    end

  end
  

  class Rule < Component
    attr_accessor :number
    attr_accessor :components
    attr_accessor :is_start

    
    def initialize n=nil
      super(n)
      @components = Array.new
      @is_start = false
    end

    def << symbol
      if symbol.is_a?(String) then
        symbol=symbol.to_sym
      end
      
      @components.push symbol
      # puts "pushed #{symbol}"
      return self
    end

  end


  class Grammar

    
         
    attr_accessor :terminals
    attr_accessor :rules

    attr_accessor :first
    attr_accessor :follow

    attr_accessor :start_rule
    
    def initialize
      @terminals = Array.new
      @rules = Array.new
      @first = Hash.new
      @follow = Hash.new

      
      x = terminal(Rpgen::eof)
      x.is_eof = true

      x = terminal(Rpgen::empty)
      x.is_empty = true
    end

    ############################################################
    # Grammar DSL
    ############################################################
    
    def terminal n
      symbol = n.to_sym

      @terminal_keys ||= Array.new
      if @terminal_keys.include? symbol then
        raise "duplicate terminal #{symbol}"
      end
      @terminal_keys.push symbol
      
      x = Terminal.new symbol
      @terminals.push( x)
      return x
    end

    def rule symbol
      x = Rule.new symbol
      x.number = @rules.count
      @rules.push( x)
      return x
    end

    def start symbol
      r = rule(Rpgen::start)
      r.is_start = true
      r << symbol << Rpgen::eof
      @start_rule = r
      return r
    end

    ############################################################
    # Helpers
    ############################################################

    def terminal_keys
      return @terminal_keys if @terminal_keys
      a = []
      @terminals.each do |x|
        a.push x.name
      end
      @terminal_keys = a
      return a
    end

    def rule_keys
      return @rule_keys if @rule_keys
      a = []
      @rules.each do |x|
        if not a.include?(x.name) then
          a.push( x.name)
        end
      end
      @rule_keys = a
      return a
    end

    def rule_map
      return @rule_map if @rule_map

      @rule_map = Hash.new
      rule_keys.each do |x|
        @rule_map[x] = Array.new
      end

      @rules.each do |rule|
        @rule_map[rule.name].push( rule)
      end

      return @rule_map
    end

    def get_rules sym
      return rule_map[sym]
    end
    
    def is_terminal sym
      terminal_keys.include? sym
    end

    def is_rule sym
      rule_keys.include? sym
    end
    
    def is_eof sym
      sym == Rpgen::eof
    end

    def is_empty sym
      sym == Rpgen::empty
    end
    
    def is_start sym
      sym == Rpgen::start
    end
    
    ############################################################
    # First
    ############################################################

    def first_init
      terminal_keys.each do |x|
        @first[x] = [x]
      end

      rule_keys.each do |x|
        @first[x] = Array.new
      end
    end

    def first_add key, x
      if x.is_a?(Array) then
        x.each do |v|
          first_add key, v
        end
        return
      end

      set = @first[key]
      unless set.include?( x) then
        set.push( x)
        @modified = true
      end
    end
    
    
    # Simple fixed-point method
    def compute_first
      first_init
      
      @modified = true
      while @modified do
        @modified = false
        
        @rules.each do |rule|
          key = rule.name
          r = first[key]
          rule.components.each do |symbol|
            a = first[symbol]
            first_add key, a
            if not a.include?(Rpgen::empty) then
              @first[key].delete_if { |x| x==Rpgen::empty }
              break
            end
          end
        end
      end
      
    end


    ############################################################
    # Follow
    ############################################################

    def follow_init
      rule_keys.each do |key|
        @follow[key] = Array.new
      end
    end

    def follow_add key, x
      if x.is_a?(Array) then
        x.each do |v|
          follow_add key, v
        end
        return
      end

      # Don't add empty to a follow set
      return if x==Rpgen::empty
      
      set = @follow[key]
      unless set.include?( x) then
        set.push( x)
        @modified = true
      end
    end
    
    
    def compute_follow
      follow_init
      
      terms = terminal_keys
      
      @modified = true
      while @modified do
        @modified = false
        
        @rules.each do |rule|
          lhs = rule.name
          rhs = rule.components

          count = rhs.count
          count.times do |dot|
            a = rhs[dot]
            next unless is_rule( a)

            # Handle final component
            if dot==(count-1) then
              follow_add( a, @follow[lhs])
              next
            end

            pos = dot+1
            res = []
            while( pos < count) do
              b = rhs[pos]
              set = @first[b]
              # TODO handle empty
              res = res.union( set)
              break
              pos += 1
            end

            follow_add( a, res)
          end
        end
        
      end
      
    end

    ############################################################
    # HTML
    ############################################################
    

    def rules_to_html
      s = ""
      s += "<table>\n"

      rules.each do |rule|
        s += "<tr>"

        s += "<td>#{rule.number}</td>\n"
        s += "<td>#{rule.name}</td>\n"

        s += "<td>"
        rule.components.each do |x|
          s += " #{x}"
        end
        s += "</td>"
        
        s += "</tr>"
      end
      
      s += "</table>\n"
      return s
    end
    
    
  end
  

end
