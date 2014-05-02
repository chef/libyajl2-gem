require 'rubygems'
require 'rake'

require 'rubygems/package_task'

GEM_NAME="libyajl2"

gemspec = eval(File.read('libyajl2.gemspec'))

Gem::PackageTask.new(gemspec) do |pkg|
  pkg.need_tar = true
end

task :install => :repackage do
  sh %{gem install pkg/#{GEM_NAME}-#{Libyajl2::VERSION}.gem --no-rdoc --no-ri}
end

task :uninstall do
  sh %{gem uninstall #{GEM_NAME} -x -v #{Libyajl2::VERSION} }
end

task :compile do
  cd "ext/libyajl2"
  ruby "extconf.rb"
end

task :clean do
  sh "git clean -fdx"
  cd "ext/libyajl2/vendor/yajl"
  sh "git clean -fdx"
end
