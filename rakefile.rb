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

task :build do
  spec = Gem::Specification.new do |s|
    # Static assignments
    s.name        = "bateman"
    s.summary     = "A thin layer over rest-client that returns JSON objects"
    s.description = <<EOF
* GET, POST, PUT, and DELETE JSON payloads
* Simple Accept headers with automatic q-score weighting
* Understand and fall back to basic Content-types if application/json is not available
* Fine-grained response handling using Bateman#resource
* A winning combination of guts, salad, sea legs, and torpor will propel our fair spaceship beyond the pale shadow of any doubt that the inxorable result of our redoubled efforts will counfound any chance at snatching defeat from the jars of whiskey.
EOF
    s.authors     = ["Rick Hull"]
    s.email       = "rick@cloudscaling.com"
    s.homepage    = "http://github.com/rickhull/bateman"
    s.licenses    = ['LGPL']

    # Dynamic assignments
    s.files       = manifest
    s.version     = version
    s.date        = Time.now.strftime("%Y-%m-%d")

    s.add_runtime_dependency  "rest-client", ["~> 1"]
    s.add_runtime_dependency         "json", ["~> 1"]
    s.add_development_dependency "minitest", [">= 0"]
    s.add_development_dependency     "rake", [">= 0"]
  end

  # we're definining the task at runtime, rather than requiretime
  # so that the gemspec will reflect any version bumping since requiretime
  #
  Gem::PackageTask.new(spec).define
  Rake::Task["package"].invoke
end

# e.g. bump(:minor, '1.2.3') #=> '1.3.0'
# only works for integers delimited by periods (dots)
#
def bump(position, version)
  pos = [:major, :minor, :patch, :build].index(position) || position
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

[:major, :minor, :patch, :build].each { |v|
  task "bump_#{v}" do
    old_version = version
    new_version = bump(v, old_version)
    puts "bumping #{old_version}  to #{new_version}"
    write_version new_version
  end
}
task :bump => [:bump_patch]

task :tag do
  tagname = "v#{version}"
  sh "git tag -a #{tagname} -m 'auto-tagged #{tagname} by Rake'"
end

task :release => [:bump_build, :tag, :publish]
task :release_patch => [:bump_patch, :tag, :publish]
task :release_minor => [:bump_minor, :tag, :publish]
task :release_major => [:bump_major, :tag, :publish]

task :verify_publish_credentials do
  creds = '~/.gem/credentials'
  fp = File.expand_path(creds)
  raise "#{creds} does not exist" unless File.exists?(fp)
  raise "can't read #{creds}" unless File.readable?(fp)
end

task :publish => [:verify_publish_credentials, :build] do
  fragment = "-#{version}.gem"
  pkg_dir = File.join(PROJECT_ROOT, 'pkg')
  Dir.chdir(pkg_dir) {
    candidates = Dir.glob "*#{fragment}"
    case candidates.length
    when 0
      raise "could not find .gem matching #{fragment}"
    when 1
      sh "gem push #{candidates.first}"
    else
      raise "multiple candidates found matching #{fragment}"
    end
  }
end
