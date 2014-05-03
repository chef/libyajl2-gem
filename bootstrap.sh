#!/bin/sh

set -e
set -x

if test -f "/etc/lsb-release" && grep -q DISTRIB_ID /etc/lsb-release; then
  platform=`grep DISTRIB_ID /etc/lsb-release | cut -d "=" -f 2 | tr '[A-Z]' '[a-z]'`
  platform_version=`grep DISTRIB_RELEASE /etc/lsb-release | cut -d "=" -f 2`
fi

compile_rubygems() {
  cd /tmp
  wget http://production.cf.rubygems.org/rubygems/rubygems-1.6.2.tgz -O - | tar zxf -
  cd rubygems-1.6.2 && ruby setup.rb --no-format-executable
  # i think this assumes running under bash
  cd -
}

case $platform in
  "ubuntu")
    export DEBIAN_FRONTEND=noninteractive
    apt-get -y -y install bc
    ubuntu_before_12_04=`echo "$platform_version >= 12.04" | bc`
    if [ $ubuntu_before_12_04 ]; then
      apt-get -q -y install ruby1.8 ruby1.8-dev rubygems1.8 libopenssl-ruby1.8
      apt-get -q -y install git-core cmake build-essential wget
      update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.8 500
      update-alternatives --install /usr/bin/gem gem /usr/bin/gem1.8 500
      update-alternatives --config ruby
      update-alternatives --config gem
      compile_rubygems
    else
      apt-get -q -y install ruby-1.9 ruby1.9.1-dev
      apt-get -q -y install git cmake build-essential
    fi
    ;;
  *)
    echo "i don't know how to setup base o/s on this platform, hope it works!"
    ;;
esac

gem install bundler --no-rdoc --no-ri

cd /tmp/kitchen/data
bundle install --without development_extras
rake compile
rake spec
