require 'buildar/tasks'
require 'rake/testtask'

Buildar.conf(__FILE__) do |b|
                b.name = 'mudbug'
    b.use_gemspec_file = true
    b.use_version_file = true
    b.version_filename = 'VERSION'
             b.use_git = true
  b.publish[:rubygems] = true
end
