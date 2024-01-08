# frozen_string_literal: true

require "test_helper"

class TestRule< Minitest::Test

  def setup
    @rule = Rpgen::Rule.new(:my_rule)
  end

  def test_super
    assert_kind_of Rpgen::Component, @rule
  end

  def test_name
    assert_equal :my_rule, @rule.name
  end

  def test_shift
    assert @rule.rhs.empty?
    @rule << :a
    refute @rule.rhs.empty?

    assert_equal @rule.rhs.first, :a
    assert_equal @rule.rhs.last, :a
  end
  
end
