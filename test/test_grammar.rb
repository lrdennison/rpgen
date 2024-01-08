# frozen_string_literal: true

require "test_helper"

class TestGrammar < Minitest::Test

  include GrammarFactory
  
  attr_accessor :grammar
  
  def setup
    @grammar = Rpgen::Grammar.new
  end


  def test_has_methods
    assert_respond_to @grammar, :terminals
    assert_respond_to @grammar, :rules

    assert_respond_to @grammar, :first
    assert_respond_to @grammar, :follow

    assert_respond_to @grammar, :eof
    assert_respond_to @grammar, :empty
    assert_respond_to @grammar, :start_lhs

    assert_respond_to @grammar, :start_rule

  end

  def test_well_known
    assert_kind_of Symbol, grammar.eof
    assert_kind_of Symbol, grammar.empty
    assert_kind_of Symbol, grammar.start_lhs

    refute_equal grammar.eof, grammar.empty
  end
  
  def test_init
    assert_equal 2, @grammar.terminals.count
    assert_empty @grammar.rules

    assert @grammar.is_terminal( grammar.eof)
    assert @grammar.is_terminal( grammar.empty)
  end
  
  def test_terminal
    @grammar.terminal :a
    assert_equal 3, @grammar.terminals.count
  end

  def test_rule
    r = @grammar.rule :a
    assert_equal 1, @grammar.rules.count
    assert_equal :a, r.lhs
  end

  def test_start
    small_grammar

    refute_nil grammar.start_rule
    
    s = grammar.start_rule
    
    assert_equal grammar.start_lhs, s.lhs
    assert_equal 2, @grammar.rules.count
  end

  def test_first_small
    small_grammar
    grammar.first_compute

    set = grammar.first[:A]
    assert_includes set, :a
    
  end

  def test_first_medium
    medium_grammar
    grammar.first_compute

    set = grammar.first[:A]
    assert_includes set, :a
    assert_includes set, :b
    refute_includes set, :c

    set = grammar.first[:B]
    refute_includes set, :a
    assert_includes set, :b
    refute_includes set, :c

    set = grammar.first[:C]
    refute_includes set, :a
    refute_includes set, :b
    assert_includes set, :c
    
  end

  
  def test_first_large
    large_grammar
    grammar.first_compute

    set = grammar.first[:D]
    assert_includes set, :d
    assert_includes set, grammar.empty

    set = grammar.first[:F]
    assert_includes set, :d
    assert_includes set, :e
    assert_includes set, :f
    refute_includes set, grammar.empty

  end


  def test_first_of
    large_grammar
    grammar.first_compute

    set = grammar.first_of []
    assert_empty set
    
    set = grammar.first_of [:A, :D]
    refute_empty set
    assert_includes set, :a
    assert_includes set, :b
    refute_includes set, :c
    refute_includes set, :d
    refute_includes set, :e
    refute_includes set, :f

  end

  def test_first_of_seq
    large_grammar
    grammar.first_compute

    set = grammar.first_of_seq [:D, :E], [:f]
    refute_empty set
    refute_includes set, grammar.empty

    refute_includes set, :a
    refute_includes set, :b
    refute_includes set, :c
    assert_includes set, :d
    assert_includes set, :e
    assert_includes set, :f
  end
  
  
end
