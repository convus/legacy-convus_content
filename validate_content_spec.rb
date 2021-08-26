# TODO: only test the files that have been changed in the branch, when on a PR
#  If the filenames are passed via an environmental variable, it should just work
#  e.g. FILENAMES="1,2,3,4" rspec validate_content_spec.rb

passed_files = ENV["FILENAMES"]&.split(",")&.map(&:strip)

hypotheses_files ||= if passed_files
  passed_files.select { |f| f.match?(/hypotheses\/.*\.yml/i) }
else
  Dir["hypotheses/*"]
end

citation_files ||= if passed_files
  passed_files.select { |f| f.match?(/citations\/.*\.yml/i) }
else
  Dir["citations/*/**"]
end

# Publications and tags are only one file
publication_files = passed_files ? (passed_files & ["publications.csv"]) : ["publications.csv"]
tag_files = passed_files ? (passed_files & ["tags.csv"]) : ["tags.csv"]

require "yaml"
require "csv"
require "json"

RSpec.describe "Hypothesess" do
  hypotheses_files.each do |file|
    context file do
      it "is a valid hypothesis yaml file" do
        YAML.load_file(file)
      end
    end
  end
end

RSpec.describe "Citations" do
  citation_files.each do |file|
    context file do
      it "is a valid citation yaml file" do
        YAML.load_file(file)
      end
    end
  end
end

RSpec.describe "Publications" do
  publication_files.each do |file|
    context file do
      it "is a valid publication csv" do
        # TODO: better validation.
        # Converting each row to json to do a little bit better validation, still seems lacking
        csv = CSV.parse(File.read(file), headers: true)
        csv.map(&:to_json)
      end
    end
  end
end

RSpec.describe "tags" do
  tag_files.each do |file|
    context file do
      it "is a valid tag csv" do
        csv = CSV.parse(File.read(file), headers: true)
        csv.map(&:to_json)
      end
    end
  end
end

# Output the filenames - useful if/when we start testing only specific files
# puts "\n\nTested files:"
# puts "  Hypotheses:\n    #{hypotheses_files.join(", ")}\n"
# puts "  Citations:\n    #{citation_files.join(", ")}\n"
# puts "  Publications:\n    #{publication_files.join(", ")}\n"
# puts "  Tags:\n    #{tag_files.join(", ")}\n"
