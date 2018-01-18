module Bruvisor
  class DS18B20

    def initialize(id)
      @file = File.join(Bruvisor::Config.get("BUS_DIR"), id) 
      @temp = 0.0
    end

    def read
      lines = File.read_lines(@file)
      if lines.size > 1
        @temp = lines[1].split("t=")[1].to_f / 1000
      else
        Bruvisor::Logger.warning("Trouble reading #{@file}")
      end
      @temp
    end
  end
end
