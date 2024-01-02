module Rpgen

  class ItemSet < Array

    attr_accessor :grammar
    attr_accessor :number
    attr_accessor :visited

    attr_accessor :parents
    attr_accessor :map          # goto table

    
    def initialize grammar
      @grammar = grammar
      @number = 0
      @visited = false
      @parent = Array.new
      @map = Hash.new
    end

    def insert item
      each do |i|
        if item.compare(i)==0 then
          puts "Duplicate item insert, skipped"
          return i
        end
      end
      push(item)
    end
    
    def dump
      puts "item set #{number}"
      each do |s|
        puts "  #{s}"
      end
    end

    def symbols_of_interest
      a = []
      self.each do |item|
        sym = item.at_dot
        next if sym.nil?
        next if grammar.is_eof(sym)
        # Termimals are needed for the transition table
        # next unless grammar.is_rule( sym)
        next if a.include?( sym)
        a.push( sym)
      end
      return a
    end

    
    def close
      todo = symbols_of_interest
      todo = todo.select { |sym| grammar.is_rule(sym) }

      # We check to see if an item is already in the item set.
      # During the closure operation, all added items have dot==0.
      # We can can just check the rule numbers.
      
      rs = Array.new
      each do |item|
        if item.dot==0 then
          rs.push item.rule.number
        end
      end

      while not todo.empty? do
        sym = todo.shift

        grammar.get_rules(sym).each do |rule|
          if rs.include?(rule.number) then
            next
          end
          
          i = Item.new( rule)
          insert( i)
          rs.push( rule.number)
          
          first = i.at_dot
          next if first.nil?
          next unless grammar.is_rule( first)
          next if todo.include?( first)
          todo.push( first)

        end
        
      end

      # sort! { |a,b| a.compare(b) }
    end


    def equals other
      return false if count!=other.count
      count.times do |ix|
        return false if self[ix].compare( other[ix]) != 0
      end
      return true
    end
    
    
    def extract sym
      result = ItemSet.new( grammar)
      result.parents = [self]

      each do |item|
        if item.matches(sym) then
          i = Item.new( item.rule)
          i.is_core = true
          i.dot = item.dot + 1
          result.push i
        end
      end
      return result
    end

    def core_items
      select { |item| item.is_core }
    end
    
    def reduce_rule
      each do |item|
        if item.at_dot.nil? then
          return item.rule.number
        end
      end
      return nil
    end


    # immediate follow sets
    def ifollow sym
      if grammar.is_start(sym) then
        return [Rpgen::eof]
      end

      matching_items = select { |item| (item.dot > 0) and (item.at_dot==sym) }

      result = []
      matching_items.each do |item|
        # FIXME
        item.grammar = grammar
        set = item.first( item.dot+1)
        result = result.union( set)
      end

      result.uniq!
      return result
    end
    

    def follow sym
      set = ifollow( sym)
      if not set.include?( Rpgen::empty) then
        return set
      end

      if parents.empty then
        set = set.delete( Rpgen::empty)
        set.push( Rpgen::eof)
        set.uniq!
        return set
      end

      matching_items = select { |item| (item.dot > 0) and (item.at_dot==sym) }
      heads = matching_items.map { |item| item.head }
      heads.uniq!
      
    end
    
    

    def kernel
      result = ItemSet.new grammar

      each do |item|
        if( grammar.is_start(item.name) || item.dot > 0) then
          result.insert( item)
          next
        end
      end

      return result
    end
    
  end


  
end
