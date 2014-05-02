exit(0) if ENV["USE_SYSTEM_LIBYAJL2"]

require 'pp'

module Libyajl2Build
  class BuildError < StandardError; end

  LIBYAJL2_VENDOR_DIR = File.expand_path("../vendor/yajl", __FILE__).freeze

  PREFIX = File.expand_path("../../../lib/libyajl2/vendored-libyajl2", __FILE__).freeze

  def self.windows?
   !!(RUBY_PLATFORM =~ /mswin|mingw|windows/)
  end

  def self.libyajl2_vendor_dir
    LIBYAJL2_VENDOR_DIR
  end

  def self.configure
    File.join(LIBYAJL2_VENDOR_DIR, "configure")
  end

  def self.prefix
    PREFIX
  end

  def self.configure_cmd
    args = %W[
      sh
      #{configure}
      --prefix=#{prefix}
    ]
  end

  def self.setup_env
    if windows?
      ENV['CC'] = 'gcc'
      ENV['CXX'] = 'g++'
    end
  end

  def self.system(*args)
    print("-> #{args.join(' ')}\n")
    super(*args)
  end

  def self.run_build_commands
    setup_env
    puts `pwd`
    puts `env`
    puts configure_cmd
    system(*configure_cmd) &&
      system("make", "clean") &&
      system("make", "-j", "5") &&
      system("make", "install")
  end

  def self.run
    Dir.chdir(libyajl2_vendor_dir) do
      run_build_commands or raise BuildError, "Failed to build libyajl2 library."
    end
  end

end

Libyajl2Build.run
