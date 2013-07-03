require 'yaml'

PROJECT_ROOT = File.dirname(__FILE__)
PROJECT_NAME = File.split(PROJECT_ROOT).last

# relative (to PROJECT_ROOT) and absolute file locations
#
REL = {
  version: 'VERSION',
  gemspec: "#{PROJECT_NAME}.gemspec",
  gemstat: 'gemspec.yaml',
}
ABS = {}
REL.each { |sym, rel| ABS[sym] = File.join(PROJECT_ROOT, rel) }

task :readable do
  [:version, :gemstat].each { |f|
    raise "can't read #{ABS[f]}" unless File.readable? ABS[f]
    puts "#{REL[f]} is readable"
  }
end

task :writable do
  [:version, :gemspec].each { |f|
    raise "can't write #{ABS[f]}" unless File.writable? ABS[f]
    puts "#{REL[f]} is writable"
  }
end

def load_file sym
  raise "Unknown sym: #{sym}" unless ABS[sym]
  contents = File.read(ABS[sym])
  case sym
  when :gemstat
    YAML.load contents
  when :version
    contents.chomp
  else
    contents
  end
end

task :loadable do
  [:version, :gemstat].each { |f|
    load_file f
    puts "#{REL[f]} is loadable"
  }
end

task :version do
  puts "#{PROJECT_NAME} #{load_file :version}"
end

task :sanity => [:readable, :loadable, :version]
task :default => [:sanity, :writable]

def file_flags(file)
  flags = []
  if File.exists?(file)
    flags << :not_readable unless File.readable?(file)
  else
    flags << :does_not_exist
  end
  flags << :not_writable unless File.writable?(file)
  flags << :ok if flags.empty?
  flags
end

task :environment do
  output = []
  output << ['PROJECT_ROOT', PROJECT_ROOT]
  output << ['PROJECT_NAME', PROJECT_NAME]

  [:version, :gemspec, :gemstat].each { |f|
    flags = file_flags(ABS[f]).map { |flag| flag.to_s.upcase }.join(', ')
    output << [f.to_s.upcase << ' FILE', REL[f], "[#{flags}]"]
  }
  output << ['VERSION', load_file(:version)]

  # column widths
  lw = 'PROJECT_ROOT'.length
  vw = PROJECT_ROOT.length
  output.each { |(label, value, flags)|
    puts [label.rjust(lw), value.ljust(vw)].join(': ') << " #{flags}"
  }
end

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

[:major, :minor, :patch].each { |v|
  task "bump_#{v}" do
    old_version = load_file :version
    new_version = bump(v, old_version)
    puts "bumping #{old_version}  to #{new_version}"
    write_file :version, new_version
  end
}
task :bump => [:bump_patch]

def gemspec
  static = load_file(:gemstat)
  dependencies = static.delete('dependencies')
  col_width = static.keys.map { |s| s.length }.max

  # the entire reason for generating the gemspec
  static['version'] = load_file(:version)
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

task :show_gemspec do
  puts gemspec
end

def write_file sym, contents
  File.open(ABS[sym], 'w') { |f| f.write(contents) }
end

task :gemspec do
  write_file :gemspec, gs
  puts "wrote #{ABS[:gemspec]}"
end
