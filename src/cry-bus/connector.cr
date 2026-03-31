module Crybus
  class Connector
    struct Segment
      getter start_adr : UInt32
      getter end_adr : UInt32
      # The function for when the segment is called to output
      # Takes an address. Returns the 8 bit data
      getter seg_out : Proc(UInt32, UInt8)
      # The function for when the segment is called to input
      # Takes an address and the 8 bit data
      getter seg_in : Proc(UInt32, UInt8, Nil)

      class SegmentLengthInvalid < Exception
      end

      def initialize(@start_adr : UInt32, length : UInt32,
        @seg_out : Proc(UInt32, UInt8), @seg_in : Proc(UInt32, UInt8, Nil))
        @end_adr = @start_adr + length - 1
        raise SegmentLengthInvalid.new("self.end_adr is less than self.start_adr!\nLength is less than 1!") if @end_adr < @start_adr
      end

      def initialize(@start_adr : UInt32,
        @seg_out : Proc(UInt32, UInt8), @seg_in : Proc(UInt32, UInt8, Nil))
        @end_adr = @start_adr
      end

      def would_hit?(address : UInt32) : Bool
        return address >= @start_adr && address <= @end_adr
      end
    end

    property bus : Bus? = nil
    getter segments : Array(Segment) = [] of Segment

    def initialize
    end

    def initialize(@bus : Bus)
      @bus.as(Bus).connect(self)
    end

    def read(address : UInt32) : UInt8
      return Random.rand(UInt8) if @bus == nil
      bus = @bus.as(Bus)
      return bus.read(address)
    end

    def write(address : UInt32, data : UInt8)
      return if @bus == nil
      bus = @bus.as(Bus)
      bus.write(address, data)
    end
  end
end