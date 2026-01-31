#! /bin/sh

bundle install
bundle exec ruby fakeserver.rb "$@"
