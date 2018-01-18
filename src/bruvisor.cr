require "./bruvisor/*"

controller = Bruvisor::Controller.new

disp = Bruvisor::CLI.new(controller)
disp.start

api = Bruvisor::API.new(controller)
api.start
