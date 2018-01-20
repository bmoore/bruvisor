require "redis"
require "json"
require "db"

module Bruvisor
  class Controller
    property goal = 32.0
    property sensor = "HLT"
    property redis_list = "temps"

    def initialize()
      @redis = Redis.new
      @redis.del(@redis_list)

      @temps = {
        "HLT": Bruvisor::DS18B20.new(Bruvisor::Config.get("HLT_SENSOR")),
        "Mash": Bruvisor::DS18B20.new(Bruvisor::Config.get("MASH_SENSOR")),
        "Kettle": Bruvisor::DS18B20.new(Bruvisor::Config.get("KETTLE_SENSOR"))
      }

      @ssr = SSR.new
      @ssr.set_pointer(@sensor)

      status
      spawn_ssr_loop
      spawn_db_loop
    end

    def spawn_ssr_loop
      spawn do
        loop do
          @ssr.set_state (@temps[@sensor].read() < @goal ? 1 : 0)
          sleep 0.1
        end
      end
    end

    def spawn_db_loop
      spawn do
        consumer = Redis.new
        db = DB.open "mysql://localhost/bru"
        loop do
          item = consumer.blpop([@redis_list], 3)
          unless item.nil?
            data = JSON.parse(item[1].to_s)
          else
            Bruvisor::Logger.debug("SO NIL")
          end
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
      status = {
        time: Time.new,
        goal: @goal,
        sensor: @sensor,
        ssr: @ssr.is_on?,
        temps: @temps.map{ |k,v| [k,v.read] }.to_h
      }

      @redis.rpush @redis_list, status.to_json.to_s

      status
    end
  end
end
