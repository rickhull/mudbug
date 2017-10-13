Gem::Specification.new do |s|
  s.name        = 'mudbug'
  s.summary     = "This hardy creature consumes JSON / REST APIs"
  s.author      = "Rick Hull"
  s.homepage    = "http://github.com/rickhull/mudbug"
  s.license     = 'LGPL-3.0'
  s.has_rdoc    = true
  s.description = "GET, POST, PUT, and DELETE JSON payloads. Easy Accept headers. Fine-grained response handling using Mudbug#resource."

  s.executables << 'mb'

  s.add_runtime_dependency  "rest-client", "~> 2.0"
  s.add_runtime_dependency         "json", ">= 1.7.7"
  s.add_runtime_dependency        "lager", "~> 1"
  s.add_runtime_dependency       "dotcfg", "~> 0.2"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency  "buildar", "~> 3.0"

  s.required_ruby_version = "~> 2"

  # set version dynamically from version file contents
  s.version  = File.read(File.join(__dir__, 'VERSION')).chomp

  s.files = %w[
    mudbug.gemspec
    VERSION
    README.md
    Rakefile
    lib/mudbug.rb
    test/mudbug.rb
    examples/accepts_and_methods.rb
    bin/mb
    doc/mb.md
  ]
end
