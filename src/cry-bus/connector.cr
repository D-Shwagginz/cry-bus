module Crybus
  # A handler for data being sent to and received from the bus
  class Connector
    # An address chunk assigned to this connector.<br>
    # Each segment takes up a portion of address space<br>
    # and has an individual output and input proc (function pointer).<br>
    #
    # Segments can act as either one connection to the bus or a
    # chain of connections which would function similarly to IO registers,
    # with each segment having a seperate output and input proc based of what
    # that register should do when being read/written.
    struct Segment
      # The address in which the bus will begin to see this segment
      getter start_adr : UInt32
      # The address in which the bus will no longer see this segment
      getter end_adr : UInt32
      # The function for when the segment is called to output.<br>
      # Takes an address. Returns the 8 bit data
      getter seg_out : Proc(UInt32, UInt8)
      # The function for when the segment is called to input.<br>
      # Takes an address and the 8 bit data
      getter seg_in : Proc(UInt32, UInt8, Nil)

      # Called when a segments end address is less than the start address
      class SegmentLengthInvalid < Exception
      end

      # Creates a new segment given its start address, size, and IO procs.
      def initialize(@start_adr : UInt32, length : UInt32,
                     @seg_out : Proc(UInt32, UInt8), @seg_in : Proc(UInt32, UInt8, Nil))
        @end_adr = @start_adr + length - 1
        raise SegmentLengthInvalid.new("self.end_adr is less than self.start_adr!\nLength is less than 1!") if @end_adr < @start_adr
      end

      # Creates a new segment given its start address and IO procs.<br>
      # end_adr is set to start_adr + 1
      def initialize(@start_adr : UInt32,
                     @seg_out : Proc(UInt32, UInt8), @seg_in : Proc(UInt32, UInt8, Nil))
        @end_adr = @start_adr
      end

      # Returns whether or not an address is within this segments address space
      def would_hit?(address : UInt32) : Bool
        return address >= @start_adr && address <= @end_adr
      end
    end

    # The bus this connector is attached to
    property bus : Bus? = nil

    # An array of segments (address spaces this connector uses)
    getter segments : Array(Segment) = [] of Segment

    # Creates a new connector with no bus
    def initialize
    end

    # Creates a new connector and auto connects a bus
    def initialize(@bus : Bus)
      @bus.as(Bus).connect(self)
    end

    # Read from the bus this connector is connected to.<br>
    # If not connected, returns a garbage value.
    def read(address : UInt32) : UInt8
      return Random.rand(UInt8) if @bus == nil
      bus = @bus.as(Bus)
      return bus.read(address)
    end

    # Writes to the buss this connector is connected to.<br>
    # If not connected, does nothing.
    def write(address : UInt32, data : UInt8)
      return if @bus == nil
      bus = @bus.as(Bus)
      bus.write(address, data)
    end
  end
end
