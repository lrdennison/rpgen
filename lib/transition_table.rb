module Rpgen

  class TransitionTable
    attr_accessor :grammar
    
    attr_accessor :item_sets
    
    def initialize
      @item_sets = Array.new
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
      
      rule = grammar.start_rule
      i = Item.new(rule)
      set.push i

      set.close
      
      return insert( set)
    end


    def generate
      set = make_initial_set
      todo = [set]
      
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
          nset.parents.push( set)
          nset.parents.uniq!

          set.map[sym] = nset
          unless nset.visited then
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
          fset = grammar.follow[red.rule.name]
          fset.each do |x|
            acts.reduce state, x, red.rule.number
          end
        end

        shifts.each do |item|
          x = item.at_dot

          if x==Rpgen::eof then
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
    


    
    def augmented_grammar
      ag = Grammar.new

      grammar.terminal_keys.each do |x|
        next if x==Rpgen::start
        next if x==Rpgen::eof
        next if x==Rpgen::empty
        ag.terminal x
      end
      
      @item_sets.each do |item_set|
        item_set.each do |item|
          if item.is_starting_item then
            rule = item.rule
            
            if rule.is_start then
              sym = rule.components.first
              n = item_set.map[sym].number
              nsym = "#{sym}-#{n}"
              ag.start nsym
              next
            end

            lhs = "#{rule.name}-#{item_set.number}".to_sym
            
            puts "creating new rule #{lhs}"
            nrule = ag.rule( lhs)
            
            rule.components.each do |sym|
              if grammar.is_terminal( sym)
                nrule << sym
              else
                n = item_set.map[sym].number
                nsym = "#{sym}-#{n}"
                nrule << nsym
              end
            end

            puts "New rhs: #{nrule.components}"
          end
        end
      end

      return ag
    end
    

    def to_html

      s = ""
      s += "<table>\n"

      item_sets.each do |item_set|
        item_set.each_with_index do |item, ix|
          s += "<tr>"

          if ix==0 then
            s += "<td>#{item_set.number}</td>\n"
          else
            s += "<td></td>\n"
          end
          
          s += "<td>#{item.to_s}</td>\n"

          
          s += "</tr>"
        end
      end
      
      s += "</table>\n"
      return s
      
    end
    
  end


end
