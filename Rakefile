require 'rake/testtask'

Rake::TestTask.new :test do |t|
  t.pattern = 'test/*.rb'
  t.warning = true
end

begin
  require 'buildar'
  Buildar.new do |b|
    b.gemspec_file = 'mudbug.gemspec'
    b.version_file = 'VERSION'
    b.use_git = true
  end
rescue LoadError
  warn "buildar tasks not available"
end
