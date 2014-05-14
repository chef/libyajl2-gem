exit(0) if ENV["USE_SYSTEM_LIBYAJL2"]

require 'rbconfig'
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

  def self.prefix
    PREFIX
  end

  def self.setup_env
  end

  # for mkmf.rb compat
  CONFIG = RbConfig::MAKEFILE_CONFIG

  def self.mkintpath(path)
    case CONFIG['build_os']
    when 'mingw32'
      path = path.dup
      path.tr!('\\', '/')
      path.sub!(/\A([A-Za-z]):(?=\/)/, '/\1')
      path
    when 'cygwin'
      if CONFIG['target_os'] != 'cygwin'
        IO.popen(["cygpath", "-u", path], &:read).chomp
      else
        path
      end
    else
      path
    end
  end

  def self.system(*args)
    print("-> #{args.join(' ')}\n")
    super(*args)
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
    File.open("#{libyajl2_vendor_dir}/src/api/yajl_version.h", "w+") do |out|
      File.open("#{libyajl2_vendor_dir}/src/api/yajl_version.h.cmake").each do |line|
        line.gsub!(/\$\{YAJL_MAJOR\}/, yajl_major)
        line.gsub!(/\$\{YAJL_MINOR\}/, yajl_minor)
        line.gsub!(/\$\{YAJL_MICRO\}/, yajl_micro)
        out.write(line)
      end
    end
  end

  def self.yajl_makefile
    File.open("Makefile", "w+") do |f|
      f.write <<EOF
SHELL = /bin/sh

# V=0 quiet, V=1 verbose.  other values don't work.
V = 0
Q1 = $(V:1=)
Q = $(Q1:0=@)
ECHO1 = $(V:1=@:)
ECHO = $(ECHO1:0=@echo)

#### Start of system configuration section. ####

srcdir = .
prefix = #{mkintpath(CONFIG['prefix'])}
rubylibprefix = $(libdir)/$(RUBY_BASE_NAME)
exec_prefix = $(prefix)
sitearchdir = $(sitelibdir)/$(sitearch)
sitelibdir = $(sitedir)/$(ruby_version)
sitedir = $(rubylibprefix)/site_ruby
libdir = $(exec_prefix)/lib

CC = #{CONFIG['CC']}
empty =
COUTFLAG = #{CONFIG['COUTFLAG']}$(empty)

cflags   = #{CONFIG['cflags']}
optflags = #{CONFIG['optflags']}
debugflags = #{CONFIG['debugflags']}
warnflags = #{CONFIG['warnflags']}
CCDLFLAGS = #{CONFIG['CCDLFLAGS']}
CFLAGS   = $(CCDLFLAGS) -I#{libyajl2_vendor_dir}/src/api -I. #{CONFIG['CFLAGS']} $(ARCH_FLAG)
INCFLAGS = -I. -I$(srcdir)
DEFS     = #{CONFIG['DEFS']}
CPPFLAGS = #{CONFIG['CPPFLAGS']} $(cppflags)
ldflags  = #{CONFIG['LDFLAGS']}
#dldflags = -Wl,-undefined,dynamic_lookup -Wl,-multiply_defined,suppress
dldflags = #{CONFIG['DLDFLAGS']} #{CONFIG['EXTDLDFLAGS']}
ARCH_FLAG = #{CONFIG['ARCH_FLAG']}
DLDFLAGS = $(ldflags) $(dldflags) $(ARCH_FLAG)
LDSHARED = #{CONFIG['LDSHARED']}

RUBY_INSTALL_NAME = #{CONFIG['RUBY_INSTALL_NAME']}
RUBY_SO_NAME = #{CONFIG['RUBY_SO_NAME']}
RUBYW_INSTALL_NAME = #{CONFIG['RUBYW_INSTALL_NAME']}
RUBY_VERSION_NAME = #{CONFIG['RUBY_VERSION_NAME']}
RUBYW_BASE_NAME = #{CONFIG['RUBYW_BASE_NAME']}
RUBY_BASE_NAME = #{CONFIG['RUBY_BASE_NAME']}

arch = #{CONFIG['arch']}
sitearch = #{CONFIG['sitearch']}
ruby_version = #{RbConfig::CONFIG['ruby_version']}
ruby = #{File.join(RbConfig::CONFIG["bindir"], CONFIG["ruby_install_name"])}
RUBY = $(ruby)

RM = $(RUBY) -run -e rm -- -f
MAKEDIRS = $(RUBY) -run -e mkdir -- -p
INSTALL = $(RUBY) -run -e install -- -vp
INSTALL_PROG = $(INSTALL) -m 0755
TOUCH = exit >

#### End of system configuration section. ####

libpath = . $(libdir)
LIBPATH = -L. -L$(libdir)

CLEANFILES = mkmf.log

target_prefix =
LIBS =  #{CONFIG['LIBS']} #{CONFIG['DLDLIBS']}
ORIG_SRCS = yajl.c yajl_alloc.c yajl_buf.c yajl_encode.c yajl_gen.c yajl_lex.c yajl_parser.c yajl_tree.c yajl_version.c
SRCS = $(ORIG_SRCS)
OBJS = yajl.o yajl_alloc.o yajl_buf.o yajl_encode.o yajl_gen.o yajl_lex.o yajl_parser.o yajl_tree.o yajl_version.o
HDRS = yajl_alloc.h yajl_buf.h yajl_bytestack.h yajl_encode.h yajl_lex.h yajl_parser.h
TARGET = libyajl
DLLIB = $(TARGET).#{CONFIG['DLEXT']}

TIMESTAMP_DIR = .
RUBYARCHDIR   = $(sitearchdir)$(target_prefix)

CLEANLIBS     = $(TARGET).bundle
CLEANOBJS     = *.o  *.bak

all:    $(DLLIB)

clean:
\t-$(Q)$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES) .*.time

install: install-so install-rb

install-so: $(DLLIB) $(TIMESTAMP_DIR)/.RUBYARCHDIR.time
\t$(INSTALL_PROG) $(DLLIB) $(RUBYARCHDIR)

install-rb:
\t$(ECHO) installing default libyajl libraries
$(TIMESTAMP_DIR)/.RUBYARCHDIR.time:
\t$(Q) $(MAKEDIRS) $(@D) $(RUBYARCHDIR)
\t$(Q) $(TOUCH) $@

.SUFFIXES: .c .o

.c.o:
\t$(ECHO) compiling $(<)
\t$(Q) $(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) $(COUTFLAG)$@ -c $<

$(DLLIB): $(OBJS) Makefile
\t$(ECHO) linking shared-object $(DLLIB)
\t-$(Q)$(RM) $(@)
\t$(Q) $(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LIBS)
\t$(Q) $(POSTLINK)

$(OBJS): $(HDRS)
EOF
    end
  end

  def self.makemakefiles
    setup_env
    generate_yajl_version
    Dir.chdir("#{libyajl2_vendor_dir}/src") do
      # hack to make includes work
      system("rm -f api/yajl")
      system("ln -s . api/yajl")
      yajl_makefile
    end
    File.open("Makefile", "w+") do |f|
      f.write <<EOF
TARGET = libyajl
DLLIB = $(TARGET).#{CONFIG['DLEXT']}
all:
\tcd #{libyajl2_vendor_dir}/src && make
\tcp #{libyajl2_vendor_dir}/src/$(DLLIB) .
install:
\tcp $(DLLIB) #{prefix}
clean:
\tcd #{libyajl2_vendor_dir}/src && make clean
EOF
    end
  end
end

Libyajl2Build.makemakefiles

