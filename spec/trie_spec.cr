require "./spec_helper"
require "../src/trie.cr"

def words
  words = %w{Haxx0r ipsum crack endif throw buffer ban ip brute force else big-endian I'm sorry Dave, I'm afraid I can't do that bit. Loop access void wombat cache function ctl-c hello world ack pragma default then stack trace irc while. Printf double gobble spoof fail true loop flood over clock James T. Kirk headers dereference January 1, 1970 /dev/null overflow script kiddies grep break server bubble sort fatal concurrently frack. Xss tcp crack ip loop hexadecimal true gc root stack trace error fopen. Packet sniffer *.* dereference system int if James T. Kirk echo man pages bang worm tunnel in default flood char deadlock Donald Knuth Public Starcraft server mutex default Leslie Lamport I'm sorry Dave, I'm afraid I can't do that. Tcp eof crack tcp mountain dew epoch cache int mainframe ack bang infinite loop memory leak buffer if. Firewall stdio.h private less break ascii else try catch stack thread chown flush flood perl double over clock}

  words.map do |word|
    word.gsub(/[\.*\/,]/, "")
  end.reject { |x| x.size == 0 }
end

describe Trie do

  context "searching" do
    it "should load words into a structure and list all"  do
      trie = Trie.new
      words.each do |word|
        trie.add(word.downcase)
      end
      res = trie.all
      res.size.should eq(114)
      trie.count.should eq(114)
    end

    it "should find similar" do
      trie = Trie.new
      words.each do |word|
        trie.add(word.downcase)
      end
      res = trie.find("sys")
      res.size.should eq(2)
      puts res.inspect
      res = trie.find("yste")
      res.size.should eq(6)

      words = res.map{|x|x.first}
      ["system", "stack", "server", "stdioh", "xss", "starcraft"].each do |w|
        words.includes?(w).should be_true
      end
    end

    it "should find buffer" do
      trie = Trie.new
      words.each do |word|
        trie.add(word.downcase)
      end

      res = trie.find("uuufer")
      res.size.should eq(1)
      res.map(&.first).includes?("buffer").should be_true

    end

    it "should find buffer 2" do
      trie = Trie.new
      trie.add("buffer")

      res = trie.find("uufer")
      puts res.inspect

      words = res.map(&.first)
      words.size.should eq(1)
      ["buffer"].each do |w|
        words.includes?(w).should be_true
      end

      trie = Trie.new
      trie.add("default")
      trie.add("devnull")

      res = trie.find("dewnul")
      words = res.map(&.first)
      words.size.should eq(1)
      ["devnull"].each do |w|
        words.includes?(w).should be_true
      end
    end

    it "should support several words in same branch" do
      trie = Trie.new
      words = %w{sol soldat solid}
      words.each do |w|
        trie.add(w.downcase)
      end

      res = trie.all
      res.size.should eq(3)
    end

    it "should find similar items beginning with" do
      trie = Trie.new
      words = %w{sol soldat solid}
      words.each do |w|
        trie.add(w.downcase)
      end

      res = trie.beginning_with("s")
      res.size.should eq(3)

      res = trie.beginning_with("sold")
      res.size.should eq(1)

      res = trie.beginning_with("soly")
      res.size.should eq(0)
    end

    it "should accept spelling errors" do
      trie = Trie.new
      words = %w{sol soldat solid}
      words.each do |w|
        trie.add(w.downcase)
      end

      res = trie.find("sldatt")
      res.size.should eq(3)
      res.map(&.first).first.should eq("soldat")

      res = trie.find("soold")
      res.size.should eq(3)
      words = res.map(&.first)
      words.includes?("soldat").should be_true
      words.includes?("sol").should be_true
      words.includes?("solid").should be_true
    end

    it "should find short words too" do
      trie = Trie.new
      words = %w{ab nu se}
      words.each do |w|
        trie.add(w.downcase)
      end
      words.size.should eq(3)
      trie.count.should eq(3)

      res = trie.find("aaab")
      res.size.should eq(1)
      res.map(&.first).first.should eq("ab")
    end
    
    it "should find short words too 2" do
      trie = Trie.new(rwd_max_nomatch_count: 2)
      words = %w{ab ad ac}
      words.each do |w|
        trie.add(w.downcase)
      end
      trie.count.should eq(3)

      trie = Trie.new(rwd_max_nomatch_count: 2)
      words = %w{ab ad ac}
      words.each do |w|
        trie.add(w.downcase)
      end
      res = trie.find("aaab")
      puts res.inspect
      res.map(&.first).first.should eq("ab")
    end

    it "should skip over nonmatching char" do
      #todo: map likely replacement chars?

      trie = Trie.new(
        rwd_max_nomatch_count: 2,
        fwd_max_nomatch_count: 1,
      )
      trie.add("bromma")
      res = trie.find("bråmma")
      puts res
      res = trie.find("brååmma")
      puts res
    end

    it "should handle large data sets" do
      trie = Trie.new(
        fwd_max_nomatch_count: 1,
        rwd_max_nomatch_count: 1,
        min_relevance: 0.8, #high value since we have a lot of items
      )
      t = Time.now
      File.each_line(File.join(File.dirname(__FILE__), "fixtures", "swe_wordlist.txt")) do |line|
        trie.add(line)
      end
      puts Time.now - t
      puts "--"

      t = Time.now
      res = trie.beginning_with("tram")
      puts res.inspect
      puts Time.now - t
      puts "--"

      t = Time.now
      res = trie.find("tramsig")
      puts res.size
      puts res[0..10].inspect
      puts Time.now - t

      t = Time.now
      res = trie.find("a")
      puts res.size
      puts res[0..10].inspect
      puts Time.now - t
      
      t = Time.now
      res = trie.find("mjäcklare")
      puts res.size
      puts res[0..10].inspect
      puts Time.now - t
      
      t = Time.now
      res = trie.find("qwe")
      puts res.size
      puts res[0..10].inspect
      puts Time.now - t
    end
  end
end
