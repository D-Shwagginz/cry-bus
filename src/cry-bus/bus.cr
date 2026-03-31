module Crybus
  class Bus
    @connectors : Array(Connector) = [] of Connector

    def connect(connector : Connector)
      connector.bus = self
      @connectors << connector unless @connectors.includes?(connector)
    end

    def disconnect(connector : Connector)
      connector.bus = nil
      @connectors.delete(connector)
    end

    def write(address : UInt32, data : UInt8)
      @connectors.each do |connector|
        connector.segments.each do |segment|
          segment.seg_in.call(address, data) if segment.start_adr >= address && segment.end_adr <= address
        end
      end
    end

    def read(address : UInt32) : UInt8
      @connectors.each do |connector|
        connector.segments.each do |segment|
          return segment.seg_out.call(address) if segment.start_adr >= address && segment.end_adr <= address
        end
      end
      return Random.rand(UInt8)
    end
  end
end