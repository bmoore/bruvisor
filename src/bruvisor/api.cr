require "kemal"

module Bruvisor
  class API
    def initialize(brew_controller : Bruvisor::Controller)
      @brew_controller = brew_controller
      logfile = File.new(Bruvisor::Config.get("API_LOGFILE"), "a+")
      Kemal.config.logger = Bruvisor::APILogger.new(logfile)
      configure_routes
    end

    def configure_routes
      get "/" do
        render "views/index.ecr"
      end
    end

    def start
      Kemal.run
    end
  end
end
