require "../spell.cr"
require "../trie.cr"
require "bk-tree/bk/tree.cr"
require "log"

abstract class AppContextProtocol
  abstract def beginning_with(word : String)
  abstract def search(word : String)
end

abstract class SearchService
  abstract def search(word : String)
  abstract def add(word : String)
end

abstract class TrieService
  abstract def beginning_with(word : String)
  abstract def add(word : String)
end

class AppContext < AppContextProtocol
  property trie_service : TrieService
  property search_service : SearchService

  def initialize(trie_service : TrieService, search_service : SearchService)
    @trie_service = trie_service
    @search_service = search_service
  end

  def add(word)
    word_sanitized = word.downcase.gsub(/[^a-zåäö]+/, "")
    @trie_service.add(word_sanitized)
    @search_service.add(word_sanitized)
  end

  def search(word)
    @search_service.search(word)
  end

  def beginning_with(word)
    @trie_service.beginning_with(word)
  end
end

# service implementations

class BruteForceSpellingSearchService < SearchService
  def initialize
    @hash = Hash(String, Int32).new
  end

  def add(word : String)
    count = @hash[word] if @hash.has_key?(word)
    @hash[word] = (count || 0) + 1
  end

  def search(word)
    return [word] if @hash.has_key?(word)

    spelling_candidates = Spell.expand(word)
    Log.info { "spelling candidates 1 size: #{spelling_candidates.size}" }
    result = scan_hash(spelling_candidates, word)
    return result if result.size > 0

    return [] of String if word.chars.size > 30

    spelling_candidates = Spell.expand2(word)
    Log.info { "spelling candidates 2 size: #{spelling_candidates.size}" }
    result = scan_hash(spelling_candidates, word)
    return result if result.size > 0

    [] of String
  end

  private def scan_hash(spelling_candidates, word)
    tot = Set(String).new
    spelling_candidates.each do |candidate|
      tot << candidate if @hash.has_key?(candidate)
    end
    return tot.to_a if tot.size > 0

    [] of String
  end
end

class BKTreeSpellingSearchService < SearchService
  def initialize
    @bk_tree = BK::Tree.new
  end

  def search(word : String)
    candidates = @bk_tree.query(word, 3)
    return candidates.values.reverse
  end

  def add(word : String)
    @bk_tree.add(word)
  end
end

class TrieServiceImpl < TrieService
  def initialize
    @trie = Trie.new
  end

  def add(word : String)
    @trie.add(word)
  end

  def beginning_with(word : String)
    @trie.beginning_with(word)
  end
end
