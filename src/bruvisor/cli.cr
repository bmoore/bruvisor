require "crt"

module Bruvisor
  class CLI
    def initialize(controller : Bruvisor::Controller)
      Crt.init
      @win = Crt::Window.new(Crt.y, Crt.x)
      @win.margin = 3
      render_border

      @cli = ""
      @status = ""
      @controller = controller
    end

    def render_border
      @win.clear
      @win.border('|', '|', '-', '-', '+', '+', '+', '+')
    end

    def run_command(cmd : String)
      args = cmd.split(" ")
      case args[0]
      when "help", "?"
        @help = true
      when "goal"
        goal = args[1]
        if goal =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/
          @controller.goal = goal.to_f
          @status = "New goal set: #{goal}"
        else
          @status = "Invalid goal: #{goal}"
        end
      when "sensor"
        sensor = args[1].downcase
        if ["hlt", "mash", "kettle"].includes? sensor
          @controller.set_ssr_sensor(sensor)
          @status = "SSR is following #{sensor}"
        else
          @status = "Invalid sensor: #{sensor}"
        end
      when "clear"
        render_border
      else
        @status = "Invalid command '#{cmd}'"
      end
    end

    def render
      render_border

      if @help
        render_help
      else
        render_status
      end

      @win.refresh
    end

    def render_help
      help_items = {
        :help => "Display the help page.",
        :goal => "Set the target temperature for the SSR - Usage: goal 184",
        :sensor => "Set which sensor to alight the SSR with - Usage: sensor HLT",
        :clear => "Clean up messy artifacts on the display."
      }
      @win.println(3, "The following commands are available. (any key to exit)")
      @win.println(4, "", spacer: "-")

      offset = 6
      large = help_items.keys.max_by { |sym| sym.to_s.size }
      help_items.each do |sym, desc|
        diff = large.to_s.size - sym.to_s.size
        @win.println(offset, "%s: %s%s" % [sym, " " * diff, desc])
        offset += 1
      end
    end

    def render_status
      controller_status = @controller.status
      render_thermometers(5, controller_status[:temps])

      onoff = controller_status[:ssr] ? "on" : "off"
      @win.println(3, "SSR following %s: %s" % [controller_status[:sensor], onoff])
      @win.println(Crt.y-3, "Command: %s" % @cli)
      @win.println(Crt.y-2, "Status: %s" % @status)
    end

    def render_thermometers(offset, temps)
      large = temps.keys.max_by { |sym| sym.to_s.size }
      temps.each do |sym, temp|
        diff = large.to_s.size - sym.to_s.size
        scale = build_therm(temp)
        @win.println(offset, "%s: %s%s" % [sym, " " * diff, scale])
        @win.println(offset+1, "%.2f" % temp, align: "center")
        offset +=3
      end
    end

    def build_therm(temp)
      width = Crt.x - 24
      ratio = [temp.to_f / 240, 1].min
      count = (ratio * width).round.to_i
      remainder = width - count
      "0 [%s%s] 240" % ["=" * count, "-" * remainder]
    end

    def read_input
      buf = @win.getch()
      if buf < 120
        if buf == 13
          @help = false
          run_command(@cli)
          @cli = ""
        elsif buf > 0
          @cli += buf.chr
        end
      end
      if buf == 263
        @cli = @cli[0..-2]
      end
    end

    def start
      spawn do
        loop do
          read_input
          render
          sleep 0.01
        end
      end
    end
  end
end
