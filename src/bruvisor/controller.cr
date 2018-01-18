module Bruvisor
  class Controller
    property goal = 32.0
    property sensor = "HLT"

    def initialize()
      @temps = {
        "HLT": Bruvisor::DS18B20.new(Bruvisor::Config.get("HLT_SENSOR")),
        "Mash": Bruvisor::DS18B20.new(Bruvisor::Config.get("MASH_SENSOR")),
        "Kettle": Bruvisor::DS18B20.new(Bruvisor::Config.get("KETTLE_SENSOR"))
      }

      @ssr = SSR.new
      @ssr.set_pointer(@sensor)

      spawn do
        loop do
          @ssr.set_state (@temps[@sensor].read() < @goal ? 1 : 0)
          sleep 0.1
        end
      end
    end

    def set_ssr_sensor(sensor)
      @sensor = sensor
      @ssr.set_pointer(@sensor)
      Bruvisor::Logger.debug("Sensor set to %s" % sensor)
    end

    def status()
      {
        goal: @goal,
        sensor: @sensor,
        ssr: @ssr.is_on?,
        temps: @temps.map{ |k,v| [k,v.read] }.to_h
      }
    end
  end
end
