exit(0) if ENV["USE_SYSTEM_LIBYAJL2"]

require 'rbconfig'
require 'fileutils'
require 'mkmf'

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

  def self.prefix
    PREFIX
  end

  def self.setup_env
    #if config['CC'] =~ /gcc/ || config['CC'] =~ /clang/
    #  config['CFLAGS'] << " -std=c99 -pedantic -Wpointer-arith -Wno-format-y2k -Wstrict-prototypes -Wmissing-declarations -Wnested-externs -Wextra  -Wundef -Wwrite-strings -Wold-style-definition -Wredundant-decls -Wno-unused-parameter -Wno-sign-compare -Wmissing-prototypes"
    #end
  end

  # since we're not using cmake we have to mangle up yajl_version.h ourselves
  def self.generate_yajl_version
    yajl_major = yajl_minor = yajl_micro = nil
    File.open("#{libyajl2_vendor_dir}/CMakeLists.txt").each do |line|
      if m = line.match(/YAJL_MAJOR (\d+)/)
        yajl_major = m[1]
      end
      if m = line.match(/YAJL_MINOR (\d+)/)
        yajl_minor = m[1]
      end
      if m = line.match(/YAJL_MICRO (\d+)/)
        yajl_micro = m[1]
      end
    end
    File.open("api/yajl_version.h", "w+") do |out|  # FIXME: relative path
      File.open("#{libyajl2_vendor_dir}/src/api/yajl_version.h.cmake").each do |line|
        line.gsub!(/\$\{YAJL_MAJOR\}/, yajl_major)
        line.gsub!(/\$\{YAJL_MINOR\}/, yajl_minor)
        line.gsub!(/\$\{YAJL_MICRO\}/, yajl_micro)
        out.write(line)
      end
    end
    FileUtils.cp "api/yajl_version.h", "yajl/yajl_version.h"
  end

  def self.copy_yajl_files
    # FIXME: resolve the relative paths in dst
    FileUtils.cp Dir["#{libyajl2_vendor_dir}/src/*.c"], '.'
    FileUtils.cp Dir["#{libyajl2_vendor_dir}/src/*.h"], '.'
    Dir.mkdir "api" unless Dir.exist?("api")
    FileUtils.cp Dir["#{libyajl2_vendor_dir}/src/api/*.h"], 'api'
    Dir.mkdir "yajl" unless Dir.exist?("yajl")
    FileUtils.cp Dir["#{libyajl2_vendor_dir}/src/api/*.h"], 'yajl'
  end

  def self.makemakefiles
    setup_env
    copy_yajl_files
    generate_yajl_version
    dir_config("libyajl")
    create_makefile("libyajl")
    # we cheat and build it right away
    system("make")
    # so we can hack up what install does later

    File.open("Makefile", "w+") do |f|
      f.write <<EOF
TARGET = libyajl
DLLIB = $(TARGET).#{RbConfig::MAKEFILE_CONFIG['DLEXT']}
all:

install:
\tmkdir -p #{prefix}/lib
\tcp $(DLLIB) #{prefix}/lib
\tmkdir -p #{prefix}/include/yajl
\tcp yajl/*.h #{prefix}/include/yajl
EOF
    end
  end
end

Libyajl2Build.makemakefiles

