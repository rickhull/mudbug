Gem::Specification.new do |s|
  s.name        = "bateman"
  s.summary     = "A thin layer over rest-client that returns JSON objects"
  s.description = "* GET, POST, PUT, and DELETE JSON payloads\n* Simple Accept headers with automatic q-score weighting\n* Understand and fall back to basic Content-types if application/json is not available\n* Fine-grained response handling using Bateman#resource\n* A winning combination of guts, salad, sea legs, and torpor will propel our fair spaceship beyond the pale shadow of a fair doubt that the unyielding results of our redoubled efforts will counfound any chance at snatching defeat from the jars of whiskey.\n"
  s.authors     = ["Rick Hull"]
  s.email       = "rick@cloudscaling.com"
  s.files       = ["lib/bateman.rb", "examples/accepts_and_methods.rb", "test/bateman.rb", "README.md", "rakefile.rb", "VERSION", "gemspec.yaml"]
  s.homepage    = "http://cloudscaling.com/"
  s.version     = "0.4.1"
  s.date        = "2013-07-03"

  s.add_runtime_dependency "rest-client", ["~> 1"]
  s.add_runtime_dependency "json", ["~> 1"]
  s.add_development_dependency "minitest", [">= 0"]
  s.add_development_dependency "rake", [">= 0"]
end