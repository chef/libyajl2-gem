$: << File.expand_path(File.join(File.dirname( __FILE__ ), "lib"))

require 'rubygems'
require 'rake'

require 'rubygems/package_task'
require 'rspec/core/rake_task'

GEM_NAME = "libyajl2"

gemspec = eval(File.read('libyajl2.gemspec'))

Gem::PackageTask.new(gemspec) do |pkg|
  pkg.need_tar = true
end

#
# build tasks
#

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

#
# test tasks
#

RSpec::Core::RakeTask.new(:spec)

if RUBY_VERSION.to_f >= 1.9
  namespace :integration do
    begin
      require 'kitchen'
    rescue LoadError
      task :vagrant do
        puts "test-kitchen gem is not installed"
      end
      task :cloud do
        puts "test-kitchen gem is not installed"
      end
    else
      desc 'Run Test Kitchen with Vagrant'
      task :vagrant do
        Kitchen.logger = Kitchen.default_file_logger
        Kitchen::Config.new.instances.each do |instance|
          instance.test(:always)
        end
      end

      desc 'Run Test Kitchen with cloud plugins'
      task :cloud do
        if ENV['TRAVIS_PULL_REQUEST'] != 'true'
          ENV['KITCHEN_YAML'] = '.kitchen.cloud.yml'
          sh "kitchen test --concurrency 4"
        end
      end
    end
  end
  namespace :style do
    desc 'Run Ruby style checks'
    begin
      require 'rubocop/rake_task'
    rescue LoadError
      task :rubocop do
        puts "rubocop gem is not installed"
      end
    else
      Rubocop::RakeTask.new(:rubocop) do |t|
        t.fail_on_error = false
      end
    end

    desc 'Run Ruby smell checks'
    begin
      require 'reek/rake/task'
    rescue LoadError
      task :reek do
        puts "reek gem is not installed"
      end
    else
      Reek::Rake::Task.new(:reek) do |t|
        t.fail_on_error = false
        t.config_files = '.reek.yml'
      end
    end
  end
else
  namespace :integration do
    task :vagrant do
      puts "test-kitchen unsupported on ruby 1.8"
    end
    task :cloud do
      puts "test-kitchen unsupported on ruby 1.8"
    end
  end
  namespace :style do
    task :rubocop do
      puts "rubocop unsupported on ruby 1.8"
    end
    task :reek do
      puts "reek unsupported on ruby 1.8"
    end
  end
end


desc 'Run all style checks'
task :style => ['style:rubocop', 'style:reek']

desc 'Run style + spec tests by default on travis'
task :travis => ['style', 'spec']

desc 'Run style, spec and test kichen on travis'
task :travis_all => ['style', 'spec', 'integration:cloud']

task :default => ['style', 'spec', 'integration:vagrant']
