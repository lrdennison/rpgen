require_relative "component.rb"

module Rpgen

  # Terminals in the grammar.
  
  class Terminal < Component
    attr_accessor :is_eof
    attr_accessor :is_empty
    
    def initialize n=nil
      super(n)
      @is_eof = false
      @is_empty = false
    end

  end
  

end
