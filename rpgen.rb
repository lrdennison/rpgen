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
  
end

grammar = SimpleGrammar.new
grammar.sum_of_products

puts
puts "--- Firsts ---"

grammar.compute_first
grammar.first.each do |k,v|
  puts "#{k} #{v}"
end

puts
puts "--- Follow ---"

grammar.compute_follow
grammar.follow.each do |k,v|
  puts "#{k} #{v}"
end

trans_table = Rpgen::TransitionTable.new
trans_table.grammar = grammar

trans_table.generate

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

acts = Rpgen::ActionTable.new( grammar, trans_table.item_sets)
acts.num_states = trans_table.item_sets.count
  
trans_table.item_sets.each do |set|
  state = set.number

  kernel = set.kernel

  reductions = kernel.select { |item| item.dot >= item.rule.components.count }
  shifts = kernel.select { |item| item.dot < item.rule.components.count }
    
  reductions.each do |red|
    fset = grammar.follow[red.rule.name]
    fset.each do |x|
      acts.reduce state, x, red.rule.number
    end
  end
    
  grammar.terminal_keys.each do |x|
    v = set.map[x]
    if v then
      acts.shift state, x, v.number
    end
  end

  grammar.rule_keys.each do |x|
    v = set.map[x]
    if v then
      acts.goto state, x, v.number
    end
  end

end

s = "<html>\n"

s += "<head>\n"

s += "<style>\n"

s += "table { border-collapse: collapse; border: 1px solid black; pad: 2px;}\n"
s += "td { color: blue; border: 1px solid black; padding-left: 10px; padding-right: 10px;}\n"

s += "</style>\n"

s += "</head>\n"

s += "<h1>Rules</h1>"
s += grammar.rules_to_html

s += "<h1>Actions</h1>"
s += acts.to_html
s += "</html>\n"

File.write("actions.html", s)

