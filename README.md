libyajl2-gem
============

[![Build Status](https://travis-ci.org/chef/libyajl2-gem.svg?branch=master)](https://travis-ci.org/chef/libyajl2-gem)
[![Code Climate](https://codeclimate.com/github/chef/libyajl2-gem.svg)](https://codeclimate.com/github/chef/libyajl2-gem)
[![Gem Version](https://badge.fury.io/rb/libyajl2.svg)](http://badge.fury.io/rb/libyajl2)

gem to install the libyajl2 c-library for distributions which do not have it

## NOTE

To build this depends on libgmp and its headers being installed.  On Ubuntu:

```
apt-get install libgmp-dev
```

If you get a mysterious "unhandled exception" build failure like:

```
Building native extensions.  This could take a while...
ERROR:  Error installing libyajl2:
  ERROR: Failed to build gem native extension.

      /home/lamont/.rvm/rubies/ruby-2.2.3/bin/ruby -r ./siteconf20151209-53133-1aq7vdk.rb extconf.rb
      creating Makefile
      /home/lamont/.rvm/gems/ruby-2.2.3/gems/libyajl2-1.2.0/ext/libyajl2
      extconf.rb:104:in `makemakefiles': unhandled exception
        from extconf.rb:138:in `<main>'

        extconf failed, exit code 1

        Gem files will remain installed in /home/lamont/.rvm/gems/ruby-2.2.3/gems/libyajl2-1.2.0 for inspection.
        Results logged to /home/lamont/.rvm/gems/ruby-2.2.3/extensions/x86_64-linux/2.2.0/libyajl2-1.2.0/gem_make.out
```

Look at the output of make.out in the same directory as extconf.rb, for my
example above that looks like:

```
# cat /home/lamont/.rvm/gems/ruby-2.2.3/gems/libyajl2-1.2.0/ext/libyajl2/make.out
compiling yajl_buf.c
compiling yajl.c
compiling yajl_gen.c
compiling yajl_tree.c
compiling yajl_encode.c
compiling yajl_parser.c
compiling yajl_alloc.c
compiling yajl_version.c
compiling yajl_lex.c
linking shared-object libyajl.so
/usr/bin/ld: cannot find -lgmp
collect2: error: ld returned 1 exit status
make: *** [libyajl.so] Error 1
```

Which gives the correct error that -lgmp was not found...

