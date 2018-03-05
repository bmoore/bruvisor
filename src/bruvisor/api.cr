require "kemal"

module Bruvisor
  class API
    def initialize(brew_controller : Bruvisor::Controller)
      @brew_controller = brew_controller
      @sockets = [] of HTTP::WebSocket
      logfile = File.new(Bruvisor::Config.get("API_LOGFILE"), "a+")
      Kemal.config.logger = Bruvisor::APILogger.new(logfile)
      configure_routes
    end

    def configure_routes
      get "/" do
        render "views/index.ecr"
      end

      get "/status" do
        @brew_controller.status.to_json.to_s
      end

      ws "/status" do |socket|
        @sockets << socket

        socket.on_message do |message|
          @sockets.each { |socket| socket.send @brew_controller.status.to_json.to_s }
        end

        socket.on_close do
          @sockets.delete socket
        end
      end
    end

    def start
      spawn do
        status = @brew_controller.status.to_json.to_s
        loop do
          @sockets.each { |socket| socket.send status }
          sleep 0.1
        end
      end
      Kemal.run
    end
  end
end
