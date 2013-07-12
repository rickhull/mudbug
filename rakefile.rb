require 'buildar'
require 'rake/testtask'

Buildar.new do |b|
  b.gemspec_file = 'mudbug.gemspec'
  b.version_file = 'VERSION'
  b.use_git = true
end

Rake::TestTask.new :test do |t|
  t.pattern = 'test/*.rb'
end
