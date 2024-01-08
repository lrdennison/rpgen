module Rpgen

  class Builder
    include GrammarFactory

    attr_accessor :grammar
    attr_accessor :trans_table
    attr_accessor :action_table

    def initialize
      @grammar = Grammar.new
      @trans_table = TransitionTable.new
      @trans_table.grammar = grammar
    end

    def build
      grammar.first_compute
      grammar.follow_compute
      
      trans_table.closure

      @action_table = trans_table.make_action_table

    end

    
    def to_html
      s = ""
      s += "<html>\n"

      s += html_head
      s += html_body

      s += "</html>\n"
      return s
    end
    
    def html_head
      s = ""
      s += "<head>\n"

      s += "<style>\n"

      s += "table { border-collapse: collapse; border: 1px solid black; pad: 2px;}\n"
      s += "th { color: blue; border: 1px solid black; padding-left: 10px; padding-right: 10px;}\n"
      s += "th.goto { background: lightyellow;}\n"
      s += "td.goto { background: lightyellow;}\n"
      s += "th.shift { background: honeydew;}\n"
      s += "td.shift { background: honeydew;}\n"
      s += "td { color: blue; border: 1px solid black; padding-left: 10px; padding-right: 10px;}\n"

      s += "</style>\n"

      s += "</head>\n"
      return s
    end
    
    def html_body
      s = ""
      s += "<body>"

      s += html_grammar
      s += html_trans_table
      s += html_action_table
      
      s += "</body>"

      return s
    end

    def html_grammar
      s = ""
      
      s += "<h1>Grammar Analysis</h1>"
      s += "<h2>Rules</h2>"
      s += grammar.rules_to_html

      s += "<h2>First and Follow</h2>"
      s += grammar.first_follow_to_html

      return s
    end

    def html_trans_table
      s = ""
      s += "<h1>LALR Analysis</h1>"
      s += "<h2>States (Item Sets)</h2>"
      s += trans_table.to_html
      return s
    end

    def html_action_table
      s = ""
      s += "<h2>Actions</h2>"
      s += "<p>\n"
      s += "Reduce means to pop state stack.  Lookup what was reduced in the goto table for the top-of-stack and push that new state."
      s += "</p>\n"

      s += action_table.to_html
      return s
    end
    
  end
  
end
