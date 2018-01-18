struct Symbol
    def to_f()
        self.to_s.to_f
    end
end

module Crt
    class Window
        property margin = 0
        def println(y : Int32, str : String, spacer = " ", align = "left")
            case align
            when "left"
                space = spacer * [Crt.x - (@margin * 2) - str.size, 0].max
                print(y, @margin, "%s%s" % [str, space])
            when "right"
                space = spacer * [Crt.x - (@margin * 2) - str.size, 0].max
                print(y, @margin, "%s%s" % [space, str])
            when "center"
                space = spacer * [Crt.x/2 - (@margin * 2) - str.size, 0].max
                print(y, @margin, "%s%s%s" % [space, str, space])
            end
        end
    end
end
