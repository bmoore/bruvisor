class ThermalMass
    getter type : String
    getter temp : Int32

    def initialize(@type)
        @temp = 400
    end

    def tick()
        @temp -= (28 + rand(8))
        if state
            @temp += 65 + rand(8)
        end
        if @temp < 54000
            @temp = 54000 + rand(500)
        end
    end

    def state()
        begin
            File.read("./#{type}_ssr.dat").to_i == 1
        rescue
            puts "hiccup"
            false
        end
    end

    def push_state
        File.open("#{@type}_temp.dat", "w") do |f|
            f.puts state
            f.puts "t=#{@temp}"
        end
    end
end

hlt = ThermalMass.new("HLT")
mash = ThermalMass.new("Mash")
kettle = ThermalMass.new("Kettle")

spawn do
    loop do
        hlt.tick
        mash.tick
        kettle.tick
        sleep 0.01
    end
end

spawn do
    loop do
        hlt.push_state
        mash.push_state
        kettle.push_state
        sleep 0.1
    end
end

loop do
    puts "#{hlt.state} and #{hlt.temp}"
    puts "#{mash.state} and #{mash.temp}"
    puts "#{kettle.state} and #{kettle.temp}"
    sleep 1
end
