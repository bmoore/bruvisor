require "yaml"

module Bruvisor
  class Config
    @@params = YAML.parse(File.read("./config.yml"))

    def self.get(param)
      @@params[param].to_s
    end

    def self.set(param, value)
      @@params[param] = value
    end
  end
end
