# Shows how you can use memory with a memory manager (cpu)
# to save data written to the bus

require "../src/cry-bus.cr"

class Memory < Crybus::Circuit
  @bytes : Array(UInt8)

  def write_byte(address : UInt32, data : UInt8)
    @bytes[address - @connector.segments[0].start_adr] = data
  end

  def read_byte(address : UInt32) : UInt8
    return @bytes[address - @connector.segments[0].start_adr]
  end

  def initialize(size : UInt32, address : UInt32, bus : Crybus::Bus, random : Bool = false)
    bus.connect(@connector)
    @bytes = random ? Array(UInt8).new(size, Random.rand(UInt8)) : Array(UInt8).new(size, 0)
    @connector.segments << Crybus::Connector::Segment.new(address, address + size, ->read_byte(UInt32), ->write_byte(UInt32, UInt8))
  end
end

class MemManager < Crybus::Circuit
  def multiply(adr1 : UInt32, adr2 : UInt32, res : UInt32)
    @connector.write(res, @connector.read(adr1) * @connector.read(adr2))
  end

  def initialize(bus : Crybus::Bus)
    bus.connect(@connector)
  end
end

bus = Crybus::Bus.new

Memory.new(3, 0, bus)
bus.write(0, 2)
bus.write(1, 6)

MemManager.new(bus)
manager.multiply(0, 1, 2)

puts "Address 0x01 reads: #{bus.read(0)}"
puts "Address 0x02 reads: #{bus.read(1)}"
puts "Address 0x03 reads: #{bus.read(2)}"
