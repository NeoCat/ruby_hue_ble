require 'ble'

class HueBLE
  VERSION = "0.1.0"

  extend Forwardable

  HUE_BLE_SERVICE_UUID = '932c32bd-0000-47a2-835a-a8d455b859dd'

  BLE::Service.add HUE_BLE_SERVICE_UUID,
                   name: 'Hue Lamp Control',
                   nick: :hue_lamp_control

  BLE::Characteristic.add '932c32bd-0002-47a2-835a-a8d455b859dd',
                          name: 'ON',
                          nick: :on,
                          vrfy: ->(x) { x == true || x == false },
                          in: ->(s) { s[0] == "\x01" },
                          out: ->(v) { v ? "\x01" : "\x00" }

  BLE::Characteristic.add '932c32bd-0003-47a2-835a-a8d455b859dd',
                          name: 'Brightness',
                          nick: :brightness,
                          vrfy: ->(x) { x >= 1 && x <= 254 },
                          in: ->(s) { s[0].ord },
                          out: ->(v) { v.chr }

  BLE::Characteristic.add '932c32bd-0004-47a2-835a-a8d455b859dd',
                          name: 'Color Temperature',
                          nick: :color_temperature,
                          vrfy: ->(x) { x >= 1 && x <= 511 },
                          in: ->(s) { s.unpack('v')[0] },
                          out: ->(v) { [v].pack('v') }

  BLE::Characteristic.add '932c32bd-0005-47a2-835a-a8d455b859dd',
                          name: 'Color a,b',
                          nick: :color,
                          vrfy: ->(x) { x.is_a?(Array) && x.size == 2 && x.all?{ |v| v >= 1 && v <= 65534 } },
                          in: ->(s) { s.unpack('v*') },
                          out: ->(v) { v.pack('v*') }

  def self.hues
    @hues ||= {}
  end

  def self.scan(adapter_name: BLE::Adapter.list.first, wait: 5)
    adapter = BLE::Adapter.new(adapter_name)
    adapter.start_discovery
    sleep(wait)
    adapter.stop_discovery

    unpaired_devices = []
    adapter.devices.each do |address|
      device = adapter[address]
      name = device.name rescue nil
      if name == 'Hue Lamp' && !device.is_paired?
        unpaired_devices << device
      elsif device.services.include?(HUE_BLE_SERVICE_UUID)
        hues[device.address] = new(device)
      end
    end

    { hues: hues, unpaired_devices: unpaired_devices }
  end

  def self.add(address, adapter_name: BLE::Adapter.list.first)
    adapter = BLE::Adapter.new(adapter_name)
    device = adapter[address]
    device.trusted = true
    unless device.is_paired?
      begin
        device.pair 
        sleep(3)
        device = adapter[address] # reload
      rescue BLE::NotAuthorized => e
        puts "Failed to pair: #{e}. Please try scanning after power off/on the bulb, getting closer, or resetting it using the smart phone app."
      end
    end
    fail "device does not have Hue Lamp Control service" unless device.services.include?(HUE_BLE_SERVICE_UUID)
    hues[address] = new(device)
  end

  def self.scan_cli(reset = false)
    puts "Scanning devices ..."
    scan_results = scan(wait: 1)
    puts "Found #{scan_results[:hues].count} Hue devices:"
    scan_results[:hues].each { |address, device| puts "  #{address}  #{device.name}" }

    if @reset
      scan_results[:hues].each { |address, device| device.remove }
      scan_results[:unpaired_devices].each { |device| device.remove }
      return
    end

    scan_results[:unpaired_devices].each do |device|
      print "Found a new #{device.name}  #{device.address} : Do you want to pair? (Y/n)> " 
      STDOUT.flush
      add(device.address) if ["Y", "y", "\n"].include? gets[0]
    end
  end


  def_delegators :@device, :address, :name, :alias, :alias=, :is_connected?, :connect, :disconnect, :pair, :is_paired?

  def initialize(device)
    @device = device
  end

  def inspect
    "#<HueBLE:#{@device.address}>"
  end

  def on?
    connect
    @device[:hue_lamp_control, :on]
  end

  def on
    connect
    @device[:hue_lamp_control, :on] = true
  end

  def off
    connect
    @device[:hue_lamp_control, :on] = false
  end

  def brightness
    connect
    @device[:hue_lamp_control, :brightness]
  end

  def brightness=(value)
    connect
    @device[:hue_lamp_control, :brightness] = value
  end

  def color_temperature
    connect
    @device[:hue_lamp_control, :color_temperature]
  end

  def color_temperature=(value)
    connect
    @device[:hue_lamp_control, :color_temperature] = value
  end

  def color
    connect
    @device[:hue_lamp_control, :color]
  end

  def color=(value)
    connect
    @device[:hue_lamp_control, :color] = value
  end
end
