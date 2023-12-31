module Rpgen

  class TransitionTable
    attr_accessor :grammar
    
    attr_accessor :item_sets
    
    def initialize
    end


    def insert item_set
      @item_sets.each do |s|
        if item_set.equals(s) then
          return s
        end
      end

      item_set.number = @item_sets.count
      @item_sets.push item_set
      item_set.dump
      return item_set
    end
    
    
    def make_initial_set
      set = ItemSet.new( grammar)
      
      rule = grammar.lookup(:S)
      i = Item.new(rule)
      set.push i
      
      # set.dump
      set.close
      set.dump

      @item_sets = [set]
    end


    def generate
      make_initial_set
      todo = [item_sets.first]
      
      while todo.count>0 do
        set = todo.shift
        next if set.visited
        set.visited = true
        
        syms = set.symbols_of_interest
        # puts "syms: #{syms}"
        syms.each do |sym|
          nset = set.extract( sym)
          nset.close

          nset = insert( nset)

          set.map[sym] = nset
          unless nset.visited then
            todo.push( nset)
          end
        end
      end
    end

    

  end


end
