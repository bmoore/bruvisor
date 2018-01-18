require "kemal"

module Bruvisor
  class Logger
    @@io = File.new(Bruvisor::Config.get("LOGFILE"), "a+")
    def self.debug(message : String)
      self.log("DEBUG", message)
    end

    def self.info(message : String)
      self.log("INFO", message)
    end

    def self.warning(message : String)
      self.log("WARN", message)
    end

    def self.error(message : String)
      self.log("ERROR", message)
    end

    def self.fatal(message : String)
      self.log("FATAL", message)
    end

    def self.log(level : String, message : String)
      time = Time.now
      @@io << time << " - (%s) %s\n" % [level, message]
      @@io.flush
    end
  end

  class APILogger < Kemal::BaseLogHandler
    @io : IO

    def initialize(@io : IO = STDOUT)
    end

    def call(context : HTTP::Server::Context)
      time = Time.now
      call_next(context)
      elapsed_text = elapsed_text(Time.now - time)
      @io << time << " " << context.response.status_code << " " << context.request.method << " " << context.request.resource << " " << elapsed_text << "\n"
      @io.flush
      context
    end

    def write(message : String)
      @io << message
      @io.flush
    end

    private def elapsed_text(elapsed)
      millis = elapsed.total_milliseconds
      return "#{millis.round(2)}ms" if millis >= 1

      "#{(millis * 1000).round(2)}µs"
    end
  end
end
