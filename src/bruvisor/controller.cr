require "redis"
require "json"
require "db"

module Bruvisor
  class Controller
    property goal = 32.0
    property sensor = "hlt"
    property redis_list = "temps"
    property therms = {} of String => DS18B20
    property temps = {} of String => Float64
    property status = {
      time: Time.new,
      goal: @goal,
      sensor: @sensor,
      ssr: false,
      temps: {} of String => Float64
    }

    def initialize()
      @redis = Redis.new
      @redis.del(@redis_list)

      ["hlt", "mash", "kettle"].each do |therm|
        add_thermometer(therm)
      end

      @ssr = SSR.new
      @ssr.set_pointer(@sensor)

      spawn_status_loop
      spawn_ssr_loop
      spawn_db_loop
    end

    def add_thermometer(therm_name)
      sensor_location = Bruvisor::Config.get("%s_sensor" % therm_name)
      @therms[therm_name] = Bruvisor::DS18B20.new(sensor_location)
      spawn do
        loop do
          @temps[therm_name] = @therms[therm_name].read
          sleep 0.1
        end
      end
    end

    def spawn_ssr_loop
      spawn do
        loop do
          @ssr.set_state (@status[:temps][@sensor] < @goal ? 1 : 0)
          sleep 0.1
        end
      end
    end

    def spawn_db_loop
      spawn do
        consumer = Redis.new
        #db = DB.open "mysql://bruvisor:bruvisor@localhost/bruvisor"
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
      @status
    end

    def spawn_status_loop()
      spawn do
        loop do
          @status = {
            time: Time.new,
            goal: @goal,
            sensor: @sensor,
            ssr: @ssr.is_on?,
            temps: @temps
          }

          @redis.rpush @redis_list, @status.to_json.to_s
          sleep 0.5
        end
      end
    end
  end
end
