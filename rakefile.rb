require 'yaml'

PROJECT_ROOT = File.dirname(__FILE__)
PROJECT_NAME = File.split(PROJECT_ROOT).last

VERSION_FILENAME = 'VERSION'
GEMSPEC_FILENAME = "#{PROJECT_NAME}.gemspec"
GEMSTAT_FILENAME = 'gemspec.yaml'

VERSION_FILE = File.join(PROJECT_ROOT, VERSION_FILENAME)
GEMSPEC_FILE = File.join(PROJECT_ROOT, GEMSPEC_FILENAME)
GEMSTAT_FILE = File.join(PROJECT_ROOT, GEMSTAT_FILENAME)

def read_version
  File.read(VERSION_FILE).chomp
end

def read_yaml(filename)
  YAML.load File.read(filename)
end

def read_static_gemspec_data
  read_yaml GEMSTAT_FILENAME
end

def write_version(version)
  File.open(VERSION_FILE, 'w') { |f| f.write(version) }
end

def write_gemspec(gemspec_code)
  File.open(GEMSPEC_FILE, 'w') { |f| f.write(gemspec_code) }
end

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

def file_flags(file)
  flags = []
  flags << :does_not_exist unless File.exists?(file)
  flags << :not_readable unless File.readable?(file)
  flags << :not_writable unless File.writable?(file)
  flags << :ok if flags.empty?
  flags
end

def gemspec
  static = read_static_gemspec_data
  dependencies = static.delete('dependencies')
  col_width = static.keys.map { |s| s.length }.max

  # the entire reason for generating the gemspec
  static['version'] = read_version
  static['date'] = Time.now.strftime("%Y-%m-%d")

  output = ['Gem::Specification.new do |s|']
  static.each { |key, value|
    output << "  s.#{key.ljust(col_width)} = #{value.inspect}"
  }
  output << ""
  if dependencies
    dependencies.each { |env, deps|
      deps.each { |dep, versions|
        method = "add_#{env}_dependency"
        output << "  s.#{method} #{dep.inspect}, #{versions.inspect}"
      }
    }
  end
  output << "end"
  output.join("\n")
end

task :readable do
  [VERSION_FILE, GEMSTAT_FILENAME].each { |path|
    puts "checking that #{path} is readable"
    raise "can't read #{path}" unless File.readable? path
  }
end

task :loadable do
  puts "loading gemspec.yaml"
  static = read_static_gemspec_data
  puts "#{PROJECT_NAME} version: #{read_version}"
end

task :writable do
  [VERSION_FILE, GEMSPEC_FILE].each { |path|
    puts "checking that #{path} is writable"
    raise "can't write #{path}" unless File.writable? path
  }
end

task :sanity => [:readable, :loadable]
task :default => [:sanity, :writable]

task :version do
  puts "#{PROJECT_NAME} #{read_version}"
end

task :bump_patch do
  old_version = read_version
  new_version = bump(:patch, old_version)
  puts "bumping #{old_version} to #{new_version}"
  write_version new_version
end

task :bump_minor do
  old_version = read_version
  new_version = bump(:minor, old_version)
  puts "bumping #{old_version} to #{new_version}"
  write_version new_version
end

task :bump_major do
  old_version = read_version
  new_version = bump(:major, old_version)
  puts "bumping #{old_version} to #{new_version}"
  write_version new_version
end

task :environment do
  # widths
  lw = 'PROJECT_ROOT'.length
  vw = PROJECT_ROOT.length
  output = []
  output << ['PROJECT_ROOT', PROJECT_ROOT]
  output << ['PROJECT_NAME', PROJECT_NAME]
  output << ['VERSION_FILE', VERSION_FILENAME, file_flags(VERSION_FILE)]
  output << ['GEMSPEC_FILE', GEMSPEC_FILENAME, file_flags(GEMSPEC_FILE)]
  output << ['GEMSTAT_FILE', GEMSTAT_FILENAME, file_flags(GEMSTAT_FILE)]
  output << ['VERSION', read_version]

  output.each { |(label, value, flags)|
    # make sure flags is a string
    case flags
    when String
      # do nothing
    when Array
      flags = flags.map { |flag| flag.to_s.upcase }.join(', ')
      flags = "[#{flags}]"
    else
      flags = ''
    end

    puts [label.rjust(lw), value.ljust(vw)].join(': ') << " #{flags}"
  }
end

task :show_gemspec do
  puts gemspec
end

task :gemspec do
  gs = gemspec
  puts
  puts "writing gemspec file as below:"
  puts
  puts gemspec
  write_gemspec gs
  puts
  puts "wrote #{GEMSPEC_FILE}"
end
