Gem::Specification.new do |s|
  s.name        = 'mudbug'
  s.summary     = "This hardy creature consumes JSON / REST APIs"
  s.author      = "Rick Hull"
  s.homepage    = "http://github.com/rickhull/mudbug"
  s.license     = 'LGPL'
  s.has_rdoc    = true
  s.description = "GET, POST, PUT, and DELETE JSON payloads. Easy Accept headers. Fine-grained response handling using Mudbug#resource."

  s.executables << 'mb'

  s.add_runtime_dependency  "rest-client", "~> 1"
  s.add_runtime_dependency         "json", "~> 1"
  s.add_runtime_dependency        "lager", ">= 0.2"
  s.add_runtime_dependency       "dotcfg", "~> 0.2"
  s.add_development_dependency "minitest", ">= 0"
  s.add_development_dependency  "buildar", "~> 1.4"

  # dynamic setup
  this_dir = File.expand_path('..', __FILE__)
  version_file = File.join(this_dir, 'VERSION')
  manifest_file = File.join(this_dir, 'MANIFEST.txt')

  # dynamic assignments
  s.version  = File.read(version_file).chomp
  s.files = File.readlines(manifest_file).map { |f| f.chomp }
end
