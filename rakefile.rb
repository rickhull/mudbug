require 'buildar/tasks'
require 'rake/testtask'

Buildar.conf(__FILE__) do |b|
  b.name = 'mudbug'
  b.use_version_file  = true
  b.version_filename  = 'VERSION'
  b.use_manifest_file = true
  b.manifest_filename = 'MANIFEST.txt'
  b.use_git           = true
  b.publish[:rubygems] =  true

  b.gemspec.summary     = "This hardy creature consumes JSON / REST APIs"
  b.gemspec.description = "GET, POST, PUT, and DELETE JSON payloads. Easy Accept headers. Fine-grained response handling using Mudbug#resource."
  b.gemspec.author      = "Rick Hull"
  b.gemspec.homepage    = "http://github.com/rickhull/mudbug"
  b.gemspec.license     = 'LGPL'

  b.gemspec.add_runtime_dependency  "rest-client", ["~> 1"]
  b.gemspec.add_runtime_dependency         "json", ["~> 1"]
  b.gemspec.add_runtime_dependency        "lager", [">= 0.2"]
  b.gemspec.add_development_dependency "minitest", [">= 0"]
  b.gemspec.add_development_dependency  "buildar", ["~> 1.2"]
end
