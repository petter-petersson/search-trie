require "./spec_helper"
require "../src/http/app_context.cr"

struct AppContextSpec::Setup
  class_property data_file = File.join(File.dirname(__FILE__), "fixtures", "swe_wordlist.txt")
  class_property words = %w{det var en gång en liten gubbe som bodde i en lådda med sina drängar bådda}

  def self.subject
    context = AppContext.new(TrieServiceImpl.new, BruteForceSpellingSearchService.new)
    words.each do |word|
      context.add(word)
    end
    context
  end

  def self.subject_with_fixture_data
    context = AppContext.new(TrieServiceImpl.new, BruteForceSpellingSearchService.new)
    w_file = File.join(File.dirname(__FILE__), "fixtures", "swe_wordlist.txt")
    File.each_line(w_file) do |line|
      context.add(line)
    end
    context
  end
end

describe AppContext do
  context "loading stores" do
    it "should return results" do
      context = AppContextSpec::Setup.subject
      result = context.search("gån")
      result.size.should eq(1)
      result.first.should eq("gång")

      result = context.search("ult")
      result.size.should eq(1)
      result.first.should eq("det")
    end

    it "should return results from large data body" do
      context = AppContextSpec::Setup.subject_with_fixture_data
      result = context.search("gån")
      result.size.should eq(17)

      result = context.search("dknko")
      result.size.should eq(5)
    end
  end
end
