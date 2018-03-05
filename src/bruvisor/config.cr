require "yaml"

module Bruvisor
  class Config
    @@params = YAML.parse(File.read("./config.yml"))

    def self.get(param)
      @@params[param.upcase].to_s
    end

    def self.set(param, value)
      @@params[param.upcase] = value
    end
  end
end
