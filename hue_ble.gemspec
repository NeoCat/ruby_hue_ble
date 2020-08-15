Gem::Specification.new do |spec|
  spec.name          = "hue_ble"
  spec.version       = "0.1.0"
  spec.authors       = ["NeoCat"]
  spec.email         = ["neocat@neocat.jp"]

  spec.summary       = %q{Control Hue light bulbs with Bluetooth LE support.}
  spec.description   = %q{Control color temperature, brightness, and color of Hue light bulbs which supports Bluetooth LE.}
  spec.homepage      = "https://github.com/NeoCat/ruby_hue_ble"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'ble'
end
