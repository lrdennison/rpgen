module Rpgen

  class ItemSet < Array

    attr_accessor :grammar
    attr_accessor :number
    attr_accessor :visited
    attr_accessor :map

    
    def initialize grammar
      @grammar = grammar
      @number = 0
      @visited = false
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
        a.unshift( sym)
      end
      return a
    end

    
    def close
      todo = symbols_of_interest

      rs = Array.new
      each do |item|
        rs.push item.rule.number
      end

      while not todo.empty? do
        sym = todo.shift
        # next if has_item( sym)

        next unless grammar.is_rule( sym)
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

      sort! { |a,b| a.compare(b) }
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

      each do |item|
        if item.matches(sym) then
          i = Item.new( item.rule)
          i.dot = item.dot + 1
          result.push i
        end
      end
      return result
    end

    def reduce_rule
      each do |item|
        if item.at_dot.nil? then
          return item.rule.number
        end
      end
      return nil
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
