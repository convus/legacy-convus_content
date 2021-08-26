# Originally this file rescued load errors, so that:
#
# > you can use your Rakefile in an environment where RSpec is unavailable
#
# ... But we only do tests with rake in this project, so we're all good

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec
