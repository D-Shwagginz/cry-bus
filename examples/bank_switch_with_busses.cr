# Shows how to bank switch between registers by
# switching the busses in which data is written to
# and read from

require "../src/cry-bus.cr"

class BankSwitch < Crybus::Circuit
  getter bus1 = Crybus::Bus.new
  getter bus2 = Crybus::Bus.new

  @is_bus1 = true

  def read(address : UInt32) : UInt8
    if @is_bus1
      return bus1.read(address)
    else
      return bus2.read(address)
    end
  end

  def write(address : UInt32, data : UInt8)
    if @is_bus1
      return bus1.write(address, data)
    else
      return bus2.write(address, data)
    end
  end

  def switch
    @is_bus1 = !@is_bus1
  end

  def initialize(bus : Crybus::Bus, address : UInt32, size : UInt32)
    bus.connect(@connector)
    @connector.segments << Crybus::Connector::Segment.new(address, size, ->read(UInt32), ->write(UInt32, UInt8))
  end
end

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
switcher = BankSwitch.new(bus, 0, 2)

reg1 = Register.new(switcher.bus1, 0)
reg2 = Register.new(switcher.bus2, 0)

puts "Writing 40 to 0x00"
bus.write(0, 40)
puts "Reading 0x00: #{bus.read(0)}"
puts "Switching bank switcher"
switcher.switch
puts "Reading 0x00: #{bus.read(0)}"
puts "Writing 20 to 0x00"
bus.write(0, 20)
puts "Reading 0x00: #{bus.read(0)}"
puts "Switching bank switcher"
switcher.switch
puts "Reading 0x00: #{bus.read(0)}"
