module Rpgen

  class ItemSet < Array

    attr_accessor :grammar
    attr_accessor :number
    attr_accessor :visited
    attr_accessor :modified

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
      item.parent = self
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
      # todo = symbols_of_interest
      # todo = todo.select { |sym| grammar.is_rule(sym) }

      pos = 0
      while pos<count do
        item = self[pos]
        pos += 1
        
        sym = item.at_dot
        next if sym.nil?
        next if grammar.is_eof(sym)
        next unless grammar.is_rule(sym)

        seq = item.post_dot
        follows = grammar.first_of_seq seq, item.follows

        grammar.get_rules(sym).each do |rule|
          i = Item.new( rule)
          
          prior = by_uid( i.uid)
          if prior then
            prior.follows = prior.follows.union(follows).sort
            next
          end
          
          i.follows = follows
          insert( i)
        end
        
      end

      # sort! { |a,b| a.compare(b) }
    end


    def close_follows
      @modified = false
      closing = true
      while closing do
        closing = false

        each do |item_a|
          sym = item_a.at_dot
          next if sym.nil?
          next if grammar.is_eof(sym)
          next unless grammar.is_rule( sym)

          seq = item_a.post_dot
          follows = grammar.first_of_seq seq, item_a.follows
          
          each do |item_b|
            next if item_b.name != sym
            cnt = item_b.follows.count
            u = item_b.follows.union( follows).sort
            if item_b.follows != u then
              item_b.follows = u
              @modified = true
              closing = true
            end
          end
        end
      end
    end
    
    
    def by_uid uid
      each do |item|
        return item if item.uid == uid
      end
      return nil
    end

    
    def same_core? other
      each do |item_a|
        next unless item_a.is_core
        item_b = other.by_uid( item_a.uid)
        return false if item_b.nil?
      end
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
    

    # This is the GOTO(I,X) function, Dragon pg. 261, done object-oriented style
    def extract sym
      result = ItemSet.new( grammar)
      result.parents = [self]

      each do |item|
        if item.matches(sym) then
          i = Item.new( item.rule)
          i.is_core = true
          i.dot = item.dot + 1

          # This is commented out, but do not delete.  It shows part
          # of the LR(1) calculation of the follows.  See
          # link_push_follows_to below.
          
          i.follows = item.follows
          result.insert i
        end
      end
      return result
    end
    

    # An extracted item set might have the same core as another item
    # set and will be combined for LALR.  We don't know that while we
    # are doing the extract.  Once we have the correct item set, we
    # can determine how to propagate the follows.
    
    def link_push_follows_to
      puts "Linking set #{number}"
      each do |item|
        x = item.at_dot
        next if x.nil?
        next if grammar.is_eof( x)

        nxt_item_set = map[x]
        puts "#{x} leads to #{nxt_item_set.number}"
        nxt_item_set.each do |nxt_item|
          next if nxt_item.rule.number != item.rule.number
          next if nxt_item.dot != (item.dot + 1)
          item.push_follows_to = nxt_item
          break
        end
        
      end
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
