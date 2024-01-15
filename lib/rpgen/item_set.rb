module Rpgen

  class ItemSet < Array

    include ParserType
    
    attr_accessor :grammar
    attr_accessor :number
    attr_accessor :modified

    attr_accessor :parents
    attr_accessor :transitions          # goto table

    
    def initialize grammar
      super()
      
      @grammar = grammar
      @number = 0
      @parent = Array.new
      @transitions = Hash.new
    end

    def insert item
      each do |i|
        if item.compare(i)==0 then
          puts "Duplicate item insert, skipped"
          return i
        end
      end
      item.parent = self
      push(item)
    end
    
    def by_uid uid
      each do |item|
        return item if item.uid == uid
      end
      return nil
    end

    
    def same_core? other
      # puts "same_core?"
      a_cores = self.select { |x| x.is_core }
      b_cores = other.select { |x| x.is_core }

      if a_cores.count==0 then
        raise "Item set with no core items?"
      end

      if b_cores.count==0 then
        raise "Item set with no core items?"
      end

      if a_cores.count!=b_cores.count then
        # puts "  Different count"
        return false
      end

      # puts "  a_cores:"
      # a_cores.each do |item|
      #   puts "    #{item}"
      # end
      # puts "  b_cores:"
      # b_cores.each do |item|
      #   puts "    #{item}"
      # end
      
      a_uids = a_cores.map { |x| x.uid }
      b_uids = b_cores.map { |x| x.uid }
      
      a_uids.sort!
      b_uids.sort!

      a_uids.count.times do |ix|
        if a_uids[ix] != b_uids[ix] then
          # puts "  UIDs are different"
          return false
        end
      end

      # puts "  item sets have the same core"
      return true
    end


    def same_core_and_follow? other
      each do |item_a|
        next unless item_a.is_core
        item_b = other.by_uid( item_a.uid)
        return false if item_b.nil?
        return false if item_a.follows.sort != item_b.follows.sort
      end
      return true
    end

    
    def is_same_as? other
      case parser_type
      when :LR0
        return same_core?(other)
      when :SLR
        return same_core?(other)
      when :LALR
        return same_core?(other)
      when :LR1
        return same_core_and_follow?(other)
      end

      raise "Unknown parser_type"
    end
    

    def merge other
      @modified = false

      if count != other.count then
        raise "Merge of incompatible item sets - count differs"
      end
      
      each do |item_a|
        item_b = other.by_uid( item_a.uid)
        if item_b.nil? then
          raise "Merge of incompatible item sets - no matching item?"
        end
        if item_a.merge(item_b) then
          @modified = true
        end
      end
      return @modified
    end

    
    def dump
      puts "  item set #{number}"
      each do |s|
        a = s.follows.join(" ")
        puts "    #{s}   #{a}"
      end
    end

    
    def kernel
      result = ItemSet.new grammar

      each do |item|
        if( grammar.is_start(item.name) || item.dot > 0) then
          result.insert( item)
        end
      end

      return result
    end

    # From the items, gather the set of symbols appearing at the
    # dot. The symbols are both terminals and rules.  These symbols
    # form the dispatch-to-next-state from this state.
    
    def symbols_of_interest
      a = []
      self.each do |item|
        sym = item.at_dot
        next if sym.nil?
        next if grammar.is_eof(sym)
        # Terminals are needed for the transition table
        # next unless grammar.is_rule( sym)
        next if a.include?( sym)
        a.push( sym)
      end
      return a
    end

    
    # This is the LR(1) closure function from the Dragon book
    
    def closure verbose=false

      if verbose then
        puts "=========="
        puts "closure of item set"
      end
      
      @modified = false
      
      todo = Array.new
      each do |item|
        todo.push( item)
      end
        
      until todo.empty? do
        item = todo.shift
        if verbose then
          s = item.follows.join(" ")
          puts "visiting #{item} with follows #{s}"
        end
        
        sym = item.at_dot
        next if sym.nil?
        next unless grammar.is_rule(sym)

        if verbose then
          puts "expanding #{sym}"
        end
        
        seq = item.post_dot
        follows = grammar.first_of_seq seq, item.follows

        if verbose then
          if seq.empty? then
            puts "  post-dot sequence contains no symbols"
          else
            s = seq.join(" ")
            puts "  post-dot sequence #{s}"
          end

          if follows.empty? then
            puts "  follows is empty"
          else
            s = follows.join(" ")
            puts "  follows is #{s}"
          end
        end
        
        
        grammar.get_rules(sym).each do |rule|
          i = Item.new( rule)
          i.follows = follows.dup
          
          prior = by_uid( i.uid)
          if prior then
            if prior.merge( i) then
              @modified = true
              todo.push( prior)
            end
            next
          end
          
          insert( i)
          todo.push( i)
          @modified = true
        end

        
      end

      if verbose then
        puts "Closure complete"
        each do |item|
          s = item.follows.join(" ")
          puts "#{item} with follows #{s}"
        end
        puts "-------------------"
      end
      
    end

      # This is the GOTO(I,X) function, Dragon pg. 261, done object-oriented style.
    
    def extract sym
      result = ItemSet.new( grammar)
      result.parser_type = parser_type
      result.parents = [self]

      each do |item|
        if item.matches(sym) then
          i = Item.new( item.rule)
          i.is_core = true
          i.dot = item.dot + 1

          i.follows = item.follows.dup
          result.insert i
        end
      end
      return result
    end
    

    def core_items
      select { |item| item.is_core }
    end
    

    # For LR(0)

    def reduce_rule
      each do |item|
        if item.at_dot.nil? then
          return item.rule.number
        end
      end
      return nil
    end



    
  end


  
end
