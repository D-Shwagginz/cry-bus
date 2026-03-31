# A more realistic implementation of bank switching.
# Uses one bus with a BankSwitch-end address modifier
# based on the current selected bank

require "../src/cry-bus.cr"

class BankSwitch < Crybus::Circuit
  getter bus = Crybus::Bus.new

  property current_bank = 0

  def read(address : UInt32) : UInt8
    return @bus.read(address + 5*@current_bank)
  end

  def write(address : UInt32, data : UInt8)
    return @bus.write(address + 5*@current_bank, data)
  end

  def initialize(bus : Crybus::Bus, address : UInt32)
    bus.connect(@connector)
    @connector.segments << Crybus::Connector::Segment.new(address, 5, ->read(UInt32), ->write(UInt32, UInt8))
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
switcher = BankSwitch.new(bus, 0)

10.times do |i|
  Register.new(switcher.bus, i.to_u32)
end

puts "Writing 1++ to 0x00-0x04"
5.times do |i|
  bus.write(i.to_u32, i.to_u8)
end
puts "Reading 0x00-0x05 (0x05 will be garbage value)"
6.times do |i|
  puts bus.read(i.to_u32)
end

puts
puts "Switching to bank 1 from bank 0"
switcher.current_bank = 1
puts

puts "Writing 5++ to 0x00-0x04"
5.times do |i|
  bus.write(i.to_u32, i.to_u8 + 5)
end
puts "Reading 0x00-0x05 (0x05 will be garbage value)"
6.times do |i|
  puts bus.read(i.to_u32)
end

puts
puts "Switching to bank 0 from bank 1"
switcher.current_bank = 0
puts

puts "Reading 0x00-0x05 (0x05 will be garbage value)"
6.times do |i|
  puts bus.read(i.to_u32)
end