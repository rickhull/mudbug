require 'rubygems/package_task'

PROJECT_ROOT = File.dirname(__FILE__)
PROJECT_NAME = File.split(PROJECT_ROOT).last
VERSION_FILE = File.join(PROJECT_ROOT, 'VERSION')
MANIFEST_FILE = File.join(PROJECT_ROOT, 'MANIFEST.txt')

def version
  File.read(VERSION_FILE).chomp
end

def manifest
  File.readlines(MANIFEST_FILE).map { |line| line.chomp }
end

task :version do
  puts "#{PROJECT_NAME} #{version}"
end

task :manifest do
  puts manifest.join("\n")
end

def gemspec
  Gem::Specification.new do |s|
    # Static assignments
    s.name        = "bateman"
    s.summary     = "A thin layer over rest-client that returns JSON objects"
    s.description = <<EOF
* GET, POST, PUT, and DELETE JSON payloads
* Simple Accept headers with automatic q-score weighting
* Understand and fall back to basic Content-types if application/json is not available
* Fine-grained response handling using Bateman#resource
* A winning combination of guts, salad, sea legs, and torpor will propel our fair spaceship beyond the pale shadow of any doubt that the unyielding results of our redoubled efforts will counfound any chance at snatching defeat from the jars of whiskey.
EOF
    s.authors     = ["Rick Hull"]
    s.email       = "rick@cloudscaling.com"
    s.homepage    = "http://cloudscaling.com/"
    s.licenses    = ['LGPL']

    # Dynamic assignments
    s.files       = manifest
    s.version     = version
    s.date        = Time.now.strftime("%Y-%m-%d")

    s.add_runtime_dependency "rest-client", ["~> 1"]
    s.add_runtime_dependency "json", ["~> 1"]
    s.add_development_dependency "minitest", [">= 0"]
    s.add_development_dependency "rake", [">= 0"]
  end
end

# i.e. task :package
Gem::PackageTask.new(gemspec) do |pkg|
  # stuff
end
task :build => [:package]

# e.g. bump(:minor, '1.2.3') #=> '1.3.0'
# only works for integers delimited by periods (dots)
#
def bump(position, version)
  pos = [:major, :minor, :patch].index(position) || position
  places = version.split('.')
  raise "bad position: #{pos} (for version #{version})" unless places[pos]
  places.map.with_index { |place, i|
    if i < pos
      place
    elsif i == pos
      place.to_i + 1
    else
      0
    end
  }.join('.')
end

def write_version new_version
  File.open(VERSION_FILE, 'w') { |f| f.write(new_version) }
end

[:major, :minor, :patch].each { |v|
  task "bump_#{v}" do
    old_version = version
    new_version = bump(v, old_version)
    puts "bumping #{old_version}  to #{new_version}"
    write_version new_version
  end
}
task :bump => [:bump_patch]
