source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.3"

gem "rake" # Ruby make, seems to be required for github actions
gem "standard" # Ruby linter

gem "rspec" # Testing

gem "fast_blank" # high performance replacement String#blank? a method that is called quite frequently in ActiveRecord

# Objective is to do annotations for failed tests. This doesn't quite get there, but maybe better than nothing?
gem "rspec-github" # Prettier github actions output
