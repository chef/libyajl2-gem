#!/bin/sh

apt-get -y install ruby ruby1.9.1-dev
apt-get -y install git
apt-get -y install cmake build-essential
gem install bundler
pwd
cd /tmp/kitchen/data
bundle install
rake compile
rake spec
