require 'rubygems'
require 'rake'

require 'rubygems/package_task'
require 'rspec/core/rake_task'

task :default => :spec

GEM_NAME="libyajl2"

gemspec = eval(File.read('libyajl2.gemspec'))

Gem::PackageTask.new(gemspec) do |pkg|
  pkg.need_tar = true
end

RSpec::Core::RakeTask.new(:spec)

desc "repackage and install #{GEM_NAME}-#{Libyajl2::VERSION}.gem"
task :install => :repackage do
  sh %{gem install pkg/#{GEM_NAME}-#{Libyajl2::VERSION}.gem --no-rdoc --no-ri}
end

desc "uninstall #{GEM_NAME}-#{Libyajl2::VERSION}.gem"
task :uninstall do
  sh %{gem uninstall #{GEM_NAME} -x -v #{Libyajl2::VERSION} }
end

desc "compile native gem"
task :compile do
  cd "ext/libyajl2"
  ruby "extconf.rb"
end

desc "clean the git repo"
task :clean do
  sh "git clean -fdx"
  cd "ext/libyajl2/vendor/yajl"
  sh "git clean -fdx"
end

