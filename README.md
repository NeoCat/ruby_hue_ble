# HueBLE

This gem enables to control Hue light bulbs which support Bluetooth LE using Ruby.

## Warning

This gem is very experimental and unstable.

- You need to factory reset Hue bulbs using smartphone apps before pairing.
- Once the pairing is lost by some reasons, you need to reset the bulbs again before reconnecting to them.
- The Hue's Bluetooth LE control interface may be subject to change in the future.
- bluez seems not to support connecting to more than 5 BLE devices at the same time. You need to disconnect and reconnect to others if you want to control more than 5 blubs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hue_ble'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install hue_ble

## Usage

At first, reset the Hue bulbs using Hue Bluetooth app on your smartphone. 
Then, you need to scan bulbs and pair with them:

```ruby
require 'hue_ble'
HueBLE.scan_cli
```

When unpaired bulbs are found, this confirms if you want to pair with them.
The BLE address is randomized on factory reset.
Your PC's BLE adapger and bulbs need to be very close (<90cm) on pairing, and the bulbs are scanned right after powered on.

This scan will also add the already paired bulbs to the HueBLE class. (So you need to scan it every time your script is launched.)

Once bulbs are added, you can control them as followings:

```ruby
def all_on
  HueBLE.hues.each_value { |hue| hue.on }
end

def all_off
  HueBLE.hues.each_value { |hue| hue.off }
end

def all_set(brightness: nil, color_temperature: nil, color: nil)
  HueBLE.hues.each_value do |hue|
    hue.brightness = brightness if brightness
    hue.color_temperature = color_temperature if color_temperature
    hue.color = color if color
  rescue BLE::Characteristic::NotFound
  end
end

def party!
  30.times do
    HueBLE.hues.each_value do |hue|
      hue.brightness = rand(253) + 1
      hue.color_temperature = rand(510) + 1
      10.times do
        hue.color = [rand(65533) + 1, rand(65533) + 1]
        break
      rescue BLE::Characteristic::NotFound
        break
      rescue
        next
      end
    end
    sleep 1
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/NeoaCat/ruby_hue_ble.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
