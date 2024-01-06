require_relative "component.rb"

module Rpgen

  class Rule < Component
    attr_accessor :number
    attr_accessor :rhs
    attr_accessor :is_start

    attr_accessor :first
    
    def initialize n=nil
      super(n)
      @rhs = Array.new
      @is_start = false
      @first = Array.new
    end

    def << symbol
      if symbol.is_a?(String) then
        symbol=symbol.to_sym
      end
      
      @rhs.push symbol
      # puts "pushed #{symbol}"
      return self
    end


    def components
      @rhs
    end

  end


end
