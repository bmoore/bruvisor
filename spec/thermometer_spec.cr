require "../src/bruvisor/thermometer"
require "minitest/autorun"

describe Bruvisor::Thermometer do

  let(:therm) {
    Bruvisor::Thermometer.new("/dev/urandom") { |f|
      temp = 0
      File.open(f, "r") do |io|
        slice = Bytes.new(4)
        io.read(slice)
        temp = slice.reduce { |a, b|
          a + b
        }
      end
      temp.to_f
    }
  }

  describe "when reading temperature" do
    it "must respond with a temperature" do
      therm.read().wont_be_nil
    end
  end
end
