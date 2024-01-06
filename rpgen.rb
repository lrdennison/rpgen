#! /usr/bin/env ruby

require_relative "lib/grammar.rb"
require_relative "lib/item.rb"
require_relative "lib/item_set.rb"
require_relative "lib/transition_table.rb"
require_relative "lib/action_table.rb"


class SimpleGrammar < Rpgen::Grammar

  def initialize
    super
  end

  # From the wikipedia on LR parsers

  def sum_of_products
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
  end

  # LR(0) Example
  def other
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
  end

  def dragon
    terminal "="
    terminal "id"
    terminal "*"
    
    rule(:S) << :L << "=" << :R
    rule(:S) << :R
    rule(:L) << "*" << :R
    rule(:L) << "id"
    rule(:R) << :L
    start(:S)
  end

  # Dragon, example 4.54
  def dragon_ex_4_54
    terminal :c
    terminal :d
    start(:S)
    rule(:S) << :C << :C
    rule(:C) << :c << :C
    rule(:C) << :d
  end

  def stanford_cs143
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
    
  end
  
end


grammar = SimpleGrammar.new
grammar.dragon_ex_4_54

puts
puts "--- Firsts ---"

grammar.first_compute
grammar.first.each do |k,v|
  puts "#{k} #{v}"
end

puts
puts "--- Follow ---"

grammar.follow_compute
grammar.follow.each do |k,v|
  puts "#{k} #{v}"
end

trans_table = Rpgen::TransitionTable.new
trans_table.grammar = grammar

trans_table.generate

# ag = trans_table.augmented_grammar
# att = Rpgen::TransitionTable.new
# att.grammar = ag
# att.generate


  
puts
puts "--- Kernels ---"

ix = 0
trans_table.item_sets.each do |set|
  kernel = set.kernel
  kernel.number = ix
  ix += 1
  kernel.dump
end

puts

print "set  "
grammar.terminal_keys.each do |x|
  print " #{x} "
end
grammar.rule_keys.each do |x|
  print " #{x} "
end

puts

acts = trans_table.make_action_table


s = "<html>\n"

s += "<head>\n"

s += "<style>\n"

s += "table { border-collapse: collapse; border: 1px solid black; pad: 2px;}\n"
s += "td { color: blue; border: 1px solid black; padding-left: 10px; padding-right: 10px;}\n"

s += "</style>\n"

s += "</head>\n"

s += "<h1>Grammar Analysis</h1>"
s += "<h2>Rules</h2>"
s += grammar.rules_to_html

s += "<h2>First and Follow</h2>"
s += grammar.first_follow_to_html


s += "<h1>LALR Analysis</h1>"
s += "<h2>States (Item Sets)</h2>"
s += trans_table.to_html


s += "<h2>Actions</h2>"
s += "<p>\n"
s += "Reduce means to pop state stack.  Lookup what was reduced in the goto table for the top-of-stack and push that new state."
s += "</p>\n"

s += acts.to_html

# s += "<h1>Augmented Rules</h1>"
# s += ag.rules_to_html

# aug_acts = att.make_action_table

# s += aug_acts.to_html

s += "</html>\n"

File.write("actions.html", s)

