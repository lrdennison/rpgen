module Rpgen

  class UniqueArray < Array

    def initialize
      super
    end

    def push_if_unique v
      if not include?(v) then
        push(v)
        return true
      end
      return false
    end

    def merge! other
      m = false
      other.each do |v|
        if push_if_unique(v) then
          m = true
        end
      end
      return m
    end
    
  end
  
end
