module Rpgen

  class ActionTable
    attr_accessor :grammar
    attr_accessor :item_sets

    attr_accessor :t_shift
    attr_accessor :t_reduce
    attr_accessor :t_goto
    attr_accessor :t_accept
    attr_accessor :num_states
    
    def initialize grammar, item_sets
      @grammar = grammar
      @item_sets = item_sets

      
      @t_shift = Hash.new
      @t_reduce = Hash.new
      @t_goto = Hash.new
      @t_accept = Hash.new

      grammar.terminal_keys.each do |x|
        @t_shift[x] = Hash.new
        @t_reduce[x] = Hash.new
        @t_accept[x] = Hash.new
      end
      
      grammar.rule_keys.each do |x|
        @t_goto[x] = Hash.new
      end
      
    end
    
    def shift state, sym, nxt
      h = @t_shift[sym]
      h[state] = nxt
    end

    def reduce state, sym, nxt
      h = @t_reduce[sym]
      h[state] = nxt
    end

    def goto state, sym, nxt
      h = @t_goto[sym]
      h[state] = nxt
    end

    def accept state, sym
      h = @t_accept[sym]
      h[state] = true
    end


    def to_html
      t_keys = grammar.terminal_keys
      t_keys.delete( grammar.empty)
      t_keys.delete(grammar.eof)
      t_keys.push(grammar.eof)

      r_keys = grammar.rule_keys
      r_keys.delete(grammar.start_lhs)

      s = ""

      s += "<table>\n"

      s += "<tr>"
      s += "<th colspan='2'></th>"
      s += "<th class='shift' colspan='#{t_keys.count}'>Shift/Reduce</th>"
      s += "<th class='goto' colspan='#{r_keys.count}'>Goto</th>"
      s += "</tr>"

      s += "<tr>"
      s += "<th>State</th>"
      s += "<th>Kernel</th>"

      

      t_keys.each do |x|
        s += "<th class='shift'>#{x}</th>"
      end
      r_keys.each do |x|
        s += "<th class='goto'>#{x}</th>"
      end
      
      s += "</tr>\n"

      
      num_states.times do |state|
        s += "<tr>\n"

        s += "<td>#{state}</td>"

        item_set = item_sets[state]

        s += "<td>"
        item_set.kernel.each do |item|
          s += item.to_s
          s += "<br/>"
        end
        s += "</td>"
        
        t_keys.each do |x|
          cnt = 0
          data = ""

          v = @t_shift[x][state]
          if( v) then
            data += " s#{v}"
            cnt += 1
          end

          v = @t_reduce[x][state]
          if( v) then
            data += " r#{v}"
            cnt += 1
          end
          
          v = @t_accept[x][state]
          if( v) then
            data += " acc"
            cnt += 1
          end
          
          if cnt<=1 then
            s += "<td class='shift'>"
          else
            s += "<td class='error'>"
          end
          
          s += data
          s += "</td>"

        end


        
        r_keys.each do |x|
          s += "<td class='goto'>"
          v = @t_goto[x][state]
          if( v) then
            s += "g#{v}"
          end

          s += "</td>"
        end
        

        s += "</tr>\n"
      end

      
      s += "</table>\n"

      return s
    end
    
  end

end
