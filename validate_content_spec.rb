# TODO: only test the files that have been changed in the branch, when on a PR
#  If the filenames are passed via an environmental variable, it should just work
#  e.g. FILENAMES="1,2,3,4" bundle exec rspec validate_content_spec.rb

passed_files = ENV["FILENAMES"]&.split(",")&.map(&:strip)

hypotheses_files ||= if passed_files
  passed_files.select { |f| f.match?(/hypotheses\/.*\.md/i) }
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

require "fast_blank"
require "yaml"
require "csv"
require "json"

# NOTE: this duplicates the class in the webapp. They should be kept in sync
class HypothesisMarkdownParser
  def initialize(file_content:)
    @file_content = file_content
  end

  attr_reader :file_content

  def split_content
    return @split_content if defined?(@split_content)
    content = @file_content.split(/^---\s*\n/)
    front = content.shift
    front = content.shift if front.blank? # First block will be blank if formatted correctly
    @split_content = [front, content.join("\n---\n")] # add back in horizontal lines, if they were in there
  end

  def front_matter
    # NOTE: difference between this and the webapp - no #with_indifferent_access
    @front_matter ||= YAML.safe_load(split_content.first)
  end

  def explanations
    return @explanations if defined?(@explanations)
    argument_numbers = []
    @explanations = split_content.last.split(/^\s*#+ explanation /i).reject(&:blank?)
      .each_with_index.map do |exp, index|
        num = exp[/\A\s*\d+/]
        num = if num.blank?
          index + 1
        else
          exp.gsub!(/\A\s*\d+/, "")
          num.to_i
        end
        num = argument_numbers.max + 1 if argument_numbers.include?(num)
        argument_numbers << num
        [num.to_s, exp.strip]
      end.to_h
  end
end

RSpec.describe "Hypothesess" do
  hypotheses_files.each do |file|
    context file do
      it "is a Hypothesis Markdown file" do
        parser = HypothesisMarkdownParser.new(file_content: File.read(file))
        # Expect there to multiple keys in the front matter
        expect(parser.front_matter.keys.length).to be > 1
        # Expect hypothesis title to be present
        hypothesis_title = parser.front_matter["hypothesis"] || ""
        expect(hypothesis_title.length).to be > 0
        expect(parser.explanations.count).to be > 0
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
