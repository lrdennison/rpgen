module Rpgen

  module ParserType

    # one of :LR0, :SLR, :LALR, :LR1

    def initialize
      @parser_type = :LALR
    end
    
    def parser_type
      @parser_type
    end

    def parser_type= value
      value = "#{value}".upcase.to_sym
      if not [:LR0, :SLR, :LALR, :LR1].include?(value) then
        raise "Unknown parser type #{value}"
      end
      
      @parser_type = value
    end
    
    def parser_type_uses_follows?
      return [:LALR, :LR1].include?(@parser_type)
    end
    
    
  end

end
