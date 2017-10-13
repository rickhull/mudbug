require 'rake/testtask'

Rake::TestTask.new :test do |t|
  t.pattern = 'test/*.rb'
  t.warning = true
end

task default: :test


#
# METRICS
#

metrics_tasks = []

begin
  require 'flog_task'

  FlogTask.new do |t|
    t.dirs = ['lib']
    t.verbose = true
  end
  metrics_tasks << :flog
rescue LoadError
  warn 'flog_task unavailable'
end

begin
  require 'flay_task'

  FlayTask.new do |t|
    t.dirs = ['lib']
    t.verbose = true
  end
  metrics_tasks << :flay
rescue LoadError
  warn 'flay_task unavailable'
end

begin
  require 'roodi_task'
  RoodiTask.new patterns: ['lib/**/*.rb']
  metrics_tasks << :roodi
rescue LoadError
  warn 'roodi_task unavailable'
end

desc "Generate code metrics reports"
task :code_metrics => metrics_tasks


#
# GEM BUILD / PUBLISH
#

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
