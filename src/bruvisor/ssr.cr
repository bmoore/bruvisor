module Bruvisor
  class SSR
    property bus_dir : String

    def initialize()
      @bus_dir = Bruvisor::Config.get("BUS_DIR")
      @is_on = 1
      @pointer = ""
    end

    def set_pointer(pointer : String)
      unless @pointer == ""
        File.write(@pointer, 0)
      end
      @pointer = File.join(@bus_dir, Bruvisor::Config.get("#{pointer}_SSR".upcase))
    end

    def set_state(state)
      @is_on = state
      File.write(@pointer, @is_on)
    end

    def is_on?
      if @is_on == 1
        true
      else
        false
      end
    end

  end
end
