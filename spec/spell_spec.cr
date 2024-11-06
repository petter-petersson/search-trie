require "./spec_helper"
require "../src/spell.cr"

describe Spell do
  context "spelling" do
    it "should create spelling alternatives to supplied word" do
      result = Spell.expand("qwärty")
      result.size.should eq(366)
    end

    it "should create second level spelling alternatives to supplied word" do
      t = Time.measure do
        result = Spell.expand2("qwärty")
        result.size.should eq(144232)
      end
      puts t
    end

    # tmp, move to type - also should entries in hash be stemmed? if input can be stemmed
    it "should find items in hash " do
      hash = Hash(String, Int32).new
      w_file = File.join(File.dirname(__FILE__), "fixtures", "swe_wordlist.txt")
      t = Time.measure do
        File.each_line(w_file) do |line|
          hash[line.downcase.gsub(/[^a-zåäö]+/, "")] = line.size
        end
      end
      puts t

      t = Time.measure do
        result = Spell.expand2("artilery")
        result.size.should eq(239748)

        tot = Set(String).new
        result.each do |res|
          tot << res if hash.has_key?(res)
        end
        tot.includes?("artilleri").should be_true
      end
      puts t

      t = Time.measure do
        result = Spell.expand2("mjäcklare")
        tot = Set(String).new
        result.each do |res|
          tot << res if hash.has_key?(res)
        end
        tot.includes?("häcklare").should be_true
        tot.includes?("mäklare").should be_true
        tot.includes?("mjällare").should be_true
      end
      puts t
    end
  end
end
