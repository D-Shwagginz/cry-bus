# Crystal Bus

A simple library used to create an IO bus and attach connectors to read and write
data on the bus.

## Installation

1. Add `cry-bus` to your `shard.yml`:
```yml
dependencies:
  cry-bus:
    github: D-Shwagginz/cry-bus
```

2. Run `shards install`

## Usage

For a guide check out the [docs](https://d-shwagginz.github.io/cry-bus/Crybus.html)

Make sure to check out the [examples](https://github.com/D-Shwagginz/cry-bus/tree/master/examples)!

Quick example of using Crybus to connect two registers to be written to and read from
on a bus:
```crystal
require "cry-bus"

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
```

You can now `bus.read(address)` and `bus.write(address, data)` to registers at 0x00 and 0x01!

## Contributing

1. Fork it (<https://github.com/your-github-user/cry-bus/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [D. Shwagginz](https://github.com/D-Shwagginz) - creator and maintainer
