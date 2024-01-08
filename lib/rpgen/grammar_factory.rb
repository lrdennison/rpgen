module GrammarFactory

  def small_grammar
    grammar.instance_eval do
      terminal :a
      
      rule(:A) << :a
      start :A

      verify
    end
  end
  

  def medium_grammar
    small_grammar
    
    grammar.instance_eval do
      terminal :b
      terminal :c
      
      rule(:A) << :B
      rule(:A) << :B << :C
      
      rule(:B) << :b

      rule(:C) << :c

      verify
    end
  end


  def large_grammar
    medium_grammar

    grammar.instance_eval do
      terminal :d
      terminal :e
      terminal :f

      rule(:D) << empty
      rule(:D) << :d

      rule(:E) << empty
      rule(:E) << :e

      rule(:F) << :D << :E << :f
      
      verify
    end
  end

  # From the wikipedia on LR parsers

  def sum_of_products_grammar
    grammar.instance_eval do
      terminal :int
      terminal :id
      terminal "+"
      terminal "*"

      rule(:Sums) << :Sums << "+" << :Products
      rule(:Sums) << :Products
      rule(:Products) << :Products << "*" << :Value
      rule(:Products) << :Value
      rule(:Value) << :int
      rule(:Value) << :id
      
      start(:Sums)
      verify
    end
  end

  # LR(0) Example
  def other_grammar
    grammar.instance_eval do
      terminal "*"
      terminal "+"
      terminal "0"
      terminal "1"

      start(:E)
      rule(:E) << :E << "*" << :B
      rule(:E) << :E << "+" << :B
      rule(:E) << :B
      rule(:B) << "0"
      rule(:B) << "1"
      verify
    end
  end

  def dragon_grammar
    grammar.instance_eval do
      terminal "="
      terminal "id"
      terminal "*"
      
      rule(:S) << :L << "=" << :R
      rule(:S) << :R
      rule(:L) << "*" << :R
      rule(:L) << "id"
      rule(:R) << :L
      start(:S)
      verify
    end
  end

  # Dragon, example 4.54
  def dragon_ex_4_54_grammar
    grammar.instance_eval do
      terminal :c
      terminal :d
      start(:S)
      rule(:S) << :C << :C
      rule(:C) << :c << :C
      rule(:C) << :d
      verify
    end
  end

  def stanford_cs143_grammar
    grammar.instance_eval do
      terminal "="
      terminal "+"
      terminal "("
      terminal ")"
      terminal :int
      terminal :id
      
      start(:S)
      rule(:S) << :V << "=" << :E
      rule(:E) << :F
      rule(:E) << :E << "+" << :F
      rule(:F) << :V
      rule(:F) << :int
      rule(:F) << "(" << :E << ")"
      rule(:V) << :id
      verify
    end
  end

end
