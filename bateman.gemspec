Gem::Specification.new do |s|
  s.name        = 'bateman'
  s.summary     = "A thin layer over rest-client that returns JSON objects"
  s.description = "It does stuff"
# below must be provided, somehow
# s.version     = "x.y.z"
# s.date        = "YYYYmmdd"
  s.authors     = ["Rick Hull"]
  s.email       = 'rick@cloudscaling.com'
  s.files       = ["lib/bateman.rb"]
  s.homepage    = 'http://gems.cloudscaling.com/'

  # just guessing on the versions, here
  s.add_runtime_dependency "rest-client", [">= 1.0"]
  s.add_runtime_dependency "json", [">= 1.0"]
  s.add_development_dependency "minitest", [">= 0"]
end
