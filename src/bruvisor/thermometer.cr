module Bruvisor
  class Thermometer

    def initialize(pointer : String, &func : String -> Float64)
      @pointer = pointer
      @parser = func
    end

    def read() : Float64
      @parser.call(@pointer)
    end

  end
end
