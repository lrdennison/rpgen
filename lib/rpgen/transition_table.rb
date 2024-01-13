module Rpgen

  class TransitionTable
    include ParserType
    
    attr_accessor :grammar
    attr_accessor :lalr
    
    attr_accessor :item_sets
    
    def initialize
      super
      @item_sets = Array.new
      @lalr = true
    end

    
    def find_match item_set
      @item_sets.each do |s|
        return s if item_set.is_same_as?(s)
      end

      return nil
    end

    
    def insert item_set
      item_set.number = @item_sets.count
      @item_sets.push item_set

      # item_set.dump
      
      return item_set
    end
    
    
    def make_initial_set
      set = ItemSet.new( grammar)
      set.parser_type = parser_type
      
      rule = grammar.start_rule
      i = Item.new(rule)
      i.is_core = true
      set.push i

      if parser_type_uses_follows? then
        i.follows.push(grammar.eof)
      end

      set.closure
      
      return insert( set)
    end


    def closure
      todo = UniqueArray.new
      todo.push(make_initial_set)
      
      until todo.empty? do
        set = todo.shift
        
        syms = set.symbols_of_interest
        puts "syms: #{syms}"
        syms.each do |sym|
          explore_new_set = true
          
          nset = set.extract( sym)
          nset.closure

          prior = find_match( nset)
          if prior then
            puts "found a prior"
            explore_new_set = false
            if parser_type==:LALR then
              prior.merge( nset)
              if prior.modified then
                explore_new_set = true
                prior.closure
              end
            end
            nset = prior
          else
            insert( nset)
          end
          
            
          nset.parents.push( set)
          nset.parents.uniq!

          set.transitions[sym] = nset

          if explore_new_set then
            todo.push_if_unique( nset)
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

          a = []
          case parser_type
          when :LR0
            a = grammar.terminal_keys
          when :SLR
            a = grammar.follow[red.rule.lhs]
          when :LALR, :LR1
            a = red.follows
          end
          
          a.each do |x|
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
            v = set.transitions[x]
            if v then
              acts.shift state, x, v.number
            end
          end

          if grammar.is_rule( x) then
            v = set.transitions[x]
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
