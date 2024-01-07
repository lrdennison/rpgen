require_relative "component.rb"
require_relative "terminal.rb"
require_relative "rule.rb"

module Rpgen

  class Grammar
    attr_accessor :terminals
    attr_accessor :rules

    # first and follow are hash maps
    # Ruby types key: Symbol, value: Array-of-Symbols
    
    attr_accessor :first
    attr_accessor :follow

    attr_accessor :start_rule
    
    # The Ruby symbols corresponding to eof (end-of-file), empty and
    # the LHS of the starting rule.
    
    attr_accessor :eof
    attr_accessor :empty
    attr_accessor :start_lhs

    def initialize
      @terminals = Array.new
      @rules = Array.new
      @first = Hash.new
      @follow = Hash.new

      
      @eof = "$".to_sym
      @start_lhs = "$S".to_sym
      @empty = "$e".to_sym

      x = terminal(eof)
      x.is_eof = true

      x = terminal(empty)
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
      r = rule(start_lhs)
      r.is_start = true
      r << symbol << eof
      @start_rule = r
      return r
    end


    def verify
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
      sym == eof
    end

    def is_empty sym
      sym == empty
    end
    
    def is_start sym
      sym == start_lhs
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

    # Simple fixed-point method.  Note that determining modified is a
    # full array comparision.  It isn't clear that the per-rule set of terminals
    # is always monotonically increasing per iteration.
    
    def first_compute
      first_init
      
      modified = true
      while modified do
        modified = false

        rule_keys.each do |key|
          terms = []
          get_rules(key).each do |rule|
            terms = terms.union(first_of(rule.rhs))
          end
          unless first[key].eql?( terms) then
            first[key] = terms
            modified = true
          end
        end
      end
    end



    def first_of seq
      result = []
      seq.each do |sym|
        result.delete(empty)
        a = first[sym]
        result = result.union( a)
        break unless a.include?(empty)
      end
      result.sort!
      return result
    end
    
    

    def first_of_seq seq, extra=nil
      result = [empty]
      seq.each do |sym|
        result.delete(empty)
        result = result.union( first[sym])
        if not result.include?(empty)
          return result
        end
      end

      # Result includes empty so add extra terminals
      if extra then
        if not extra.is_a?(Array) then
          raise "Not an array"
        end
        result.delete(empty)
        result = result.union( extra)
      end
      
      return result
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
      return if x==empty
      
      set = @follow[key]
      unless set.include?( x) then
        set.push( x)
        @modified = true
      end
    end
    
    
    def follow_compute
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

    
    def first_follow_to_html
      
      s = ""
      s += "<table>\n"

      rule_keys.each do |key|
        s += "<tr>"

        s += "<td>#{key}</td>\n"
        t = first[key].join(",")
        s += "<td>#{t}</td>\n"
        t = follow[key].join(",")
        s += "<td>#{t}</td>\n"

        
        s += "</tr>"
      end
      
      s += "</table>\n"
      return s
    end
    
  end
  

end
