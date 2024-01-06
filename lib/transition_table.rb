module Rpgen

  class TransitionTable
    attr_accessor :grammar
    attr_accessor :lalr
    
    attr_accessor :item_sets
    
    def initialize
      @item_sets = Array.new
      @lalr = false
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

      prior = find_match(item_set)

      if prior then

        if @lalr then
          item_set.each do |item_a|
            prior.each do |item_b|
              if item_a.uid == item_b.uid then
                item_b.follows = item_b.follows.union( item_a.follows).sort
              end
            end
          end
        end

        return prior
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
      i.follows.push(grammar.eof)

      set.close
      
      return insert( set)
    end


    def generate_lr0
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
          nset.close_follows
          nset = insert( nset)

          nset.parents.push( set)
          nset.parents.uniq!

          set.map[sym] = nset
          unless nset.visited then
            todo.push( nset)
          end
        end
      end

      item_sets.each do |set|
        set.link_push_follows_to
      end
      
    end


    def close_follows
      closing = true
      
      while closing do
        closing = false

        item_sets.each do |set|

          set.close_follows
        
          if set.modified then
            puts "Set #{set.number} modified"
            closing = true

            set.each do |item|
              nxt = item.push_follows_to
              if nxt then
                # puts "#{item} => #{nxt}"
                u = nxt.follows.union( item.follows).sort
                if u != nxt.follows then
                  nxt.follows = u
                  nxt_set = nxt.parent
                  closing = true
                  # unless todo.include?( nxt_set) then
                  #   todo.push( nxt_set)
                  # end
                end
              end
            end
          end
        end
        
      end
      
    end

    
    def generate
      generate_lr0
      # close_follows
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
