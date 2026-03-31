module Crybus::Circuits
  class Memory < Circuit
    @bytes : Array(UInt8)

    def write_byte(address : UInt32, data : UInt8)
      @bytes[address - @connector.segments[0].start_adr] = data
    end

    def read_byte(address : UInt32) : UInt8
      return @bytes[address - @connector.segments[0].start_adr]
    end

    def initialize(size : UInt32, address : UInt32, random : Bool = false)
      @bytes = random ? Array(UInt8).new(size, Random.rand(UInt8)) : Array(UInt8).new(size, 0)
      @connector.segments << Connector::Segment.new(address, address + size, ->read_byte(UInt32), ->write_byte(UInt32, UInt8))
    end
  end
end