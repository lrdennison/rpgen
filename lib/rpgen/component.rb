module Rpgen

  # A common base class for both Terminals and Rules
  
  class Component
    attr_accessor :name

    def initialize n=nil
      if n.is_a?(String) then
        n = n.to_sym
      end
      @name = n
    end
  end

end
