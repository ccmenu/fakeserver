#! /bin/sh

bundle install --path vendor/bundle
bundle config set --local path 'vendor/bundle'
bundle exec ruby fakeserver.rb
