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
    it "should load words into a structure and list all" do
      trie = Trie.new
      words.each do |word|
        trie.add(word.downcase)
      end
      res = trie.all
      res.size.should eq(114)
      trie.count.should eq(114)
    end

    it "supports several words in same node branch" do
      trie = Trie.new
      words = %w{sol soldat solid}
      words.each do |w|
        trie.add(w.downcase)
      end

      res = trie.all
      res.size.should eq(3)
    end

    it "finds similar items beginning with" do
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

    it "handles large data sets" do
      trie = Trie.new

      w_file = File.join(File.dirname(__FILE__), "fixtures", "swe_wordlist.txt")
      t = Time.measure do
        File.each_line(w_file) do |line|
          trie.add(line.downcase.gsub(/[^a-zåäö]+/, ""))
        end
      end
      puts t
      puts "--"

      t = Time.measure do
        res = trie.beginning_with("tram")
        res.size.should eq(60)
      end
      puts t

      t = Time.measure do
        res = trie.beginning_with("artilleri")
        puts res
      end
      puts t
    end
  end
end
