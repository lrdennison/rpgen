module Rpgen

  class TransitionTable
    attr_accessor :grammar
    attr_accessor :lalr
    
    attr_accessor :item_sets
    
    def initialize
      @item_sets = Array.new
      @lalr = true
    end

    def find_match item_set

      @item_sets.each do |s|
        if @lalr then
          return s if item_set.same_core?(s)
        else
          return s if item_set.same_core_and_follow?(s)
        end
      end

      return nil
    end

    
    def insert item_set
      item_set.modified = false
      prior = find_match(item_set)

      if prior then
        if @lalr then
          prior.merge( item_set)
        end
        return prior
      end
      
      item_set.number = @item_sets.count
      @item_sets.push item_set

      # item_set.dump
      
      return item_set
    end
    
    
    def make_initial_set
      set = ItemSet.new( grammar)
      
      rule = grammar.start_rule
      i = Item.new(rule)
      set.push i
      i.follows.push(grammar.eof)

      set.closure
      
      return insert( set)
    end


    def closure
      todo = [make_initial_set]
      
      until todo.empty? do
        set = todo.shift
        
        syms = set.symbols_of_interest
        # puts "syms: #{syms}"
        syms.each do |sym|
          nset = set.extract( sym)
          nset.closure

          pset = insert( nset)

          pset.parents.push( set)
          pset.parents.uniq!

          set.map[sym] = pset

          if nset==pset or pset.modified then
            pset.closure
            todo.push( nset)
          end
          
        end
      end

    end


    def make_action_table
      acts = Rpgen::ActionTable.new( grammar, item_sets)
      acts.num_states = item_sets.count
      
      item_sets.each do |set|
        state = set.number

        kernel = set.kernel

        reductions = set.select { |item| item.dot >= item.rule.components.count }
        shifts = set.select { |item| item.dot < item.rule.components.count }
        
        reductions.each do |red|
          red.follows.each do |x|
            acts.reduce state, x, red.rule.number
          end
        end

        shifts.each do |item|
          x = item.at_dot

          if x==grammar.eof then
            acts.accept state, x
            next
          end
          
          if grammar.is_terminal( x) then
            v = set.map[x]
            if v then
              acts.shift state, x, v.number
            end
          end

          if grammar.is_rule( x) then
            v = set.map[x]
            if v then
              acts.goto state, x, v.number
            end
          end

        end
        
      end
      return acts
    end
    


    
    def to_html

      s = ""
      s += "<table>\n"

      s += "<tr>"
      s += "<th>State</th>"
      s += "<th>Item</th>"
      s += "<th>Follows</th>"
      s += "</tr>"
      
      item_sets.each do |item_set|
        item_set.each_with_index do |item, ix|
          s += "<tr>"

          if ix==0 then
            s += "<td>#{item_set.number}</td>\n"
          else
            s += "<td></td>\n"
          end
          
          s += "<td>#{item.to_s}</td>\n"

          t = item.follows.join(" ")
          s += "<td>#{t}</td>\n"

          
          s += "</tr>"
        end
      end
      
      s += "</table>\n"
      return s
      
    end
    
  end


end
