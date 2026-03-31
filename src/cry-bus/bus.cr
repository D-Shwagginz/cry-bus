module Crybus
  # The Bus
  #
  # A connector handler.<br>
  # Controls connectors being connected, disconnected, written to, and read from.<br>
  class Bus
    @connectors : Array(Connector) = [] of Connector

    # Connects a connector to the bus
    def connect(connector : Connector)
      connector.bus = self
      @connectors << connector unless @connectors.includes?(connector)
    end

    # Disconnects a connector from the bus
    def disconnect(connector : Connector)
      connector.bus = nil
      @connectors.delete(connector)
    end

    # Writes to an address.<br>
    # If a connector is at that address, call the input for that connectors segment.
    def write(address : UInt32, data : UInt8)
      @connectors.each do |connector|
        connector.segments.each do |segment|
          segment.seg_in.call(address, data) if segment.would_hit?(address)
        end
      end
    end

    # Reads from an address.<br>
    # If a connector is at that address, returns the output of that connectors segment,<br>
    # otherwise return a garbage value.
    def read(address : UInt32) : UInt8
      @connectors.each do |connector|
        connector.segments.each do |segment|
          return segment.seg_out.call(address) if segment.would_hit?(address)
        end
      end
      return Random.rand(UInt8)
    end
  end
end
