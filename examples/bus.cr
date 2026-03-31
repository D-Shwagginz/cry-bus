# Shows how to use the bus to read and write data to registers

require "../src/cry-bus.cr"

class Register < Crybus::Circuit
  @data : UInt8 = 0

  def output(address : UInt32) : UInt8
    return @data
  end

  def input(address : UInt32, data : UInt8)
    @data = data
  end

  def initialize(bus : Crybus::Bus, address : UInt32)
    bus.connect(@connector)
    @connector.segments << Crybus::Connector::Segment.new(address, ->output(UInt32), ->input(UInt32, UInt8))
  end
end

bus = Crybus::Bus.new

Register.new(bus, 0)
Register.new(bus, 1)

puts "Reading address 0: #{bus.read(0)}"
puts "Reading address 1: #{bus.read(1)}"
puts "Reading address 2 (disconnected): #{bus.read(2)}"

puts "Writing value 100 to address 0"
puts "Writing value 255 to address 1"
puts "Writing value 255 to address 2 (disconnected)"
bus.write(0, 100)
bus.write(1, 255)
bus.write(2, 255)

puts "Reading address 0: #{bus.read(0)}"
puts "Reading address 1: #{bus.read(1)}"
puts "Reading address 2 (disconnected): #{bus.read(2)}"
